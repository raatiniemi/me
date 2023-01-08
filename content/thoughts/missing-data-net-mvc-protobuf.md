+++
title = "Missing data when using .NET MVC and protobuf"
date = "2021-10-31"
+++

Last week I notice an issue in one of our projects at work, the project in question is a C# API using .NET MVC and since we have multiple consumers we use protobuf for data serialization.

The issue was that not all data sent to the endpoint was available in the controller method, this issue was only affecting our `HTTP POST`/`HTTP PUT` endpoints that was using a custom message as a `repeated` field in our protobuf declaration.

The data missing from the incoming data was of course the data for the `repeated` field, everything else seemed to work as intended. Ehm, perhaps not everything, we also had issues with `enum` properties not being mapped correctly. Both of these issues turned out to be caused by the same underlying issue.

In .NET MVC, if you are using a custom data type (`class`, `record`, etc.) as an argument for a `HTTP` exposed controller method, the value will be deserialized using the best effort approach. Don't get me wrong it works well, unless you venture off the beaten path. I would consider our issues here a bit of an edge case as it did work if we'd use any other class, with the same properties, than the one generated from our protobuf declaration.

Based on my current understanding, the issue is with .NET MVC not handling the `RepeatedField` as intended. I've yet to figure out why that is as the `RepeatedField` implements but `IList<T>` and `IList`, which should be enough. The issue with the `enum` properties was that the order of the enum cases was different in our protobuf declaration than in the C# enum, and the .NET MVC deserialization process was mapping based on the index and not name/value.

The solution to both of our issues is to not rely on the deserialization process from .NET MVC and instead handle it on our own. I've tried to find a way to both confirm that this was the actual issue and implement the solution, and yesterday a colleague pointed me down the right path. Ensuring that the data is parsed using the actual protobuf declaration can be done via `TextInputFormatter`s.

Using an `TextInputFormatter` to parse the data with the protobuf parser requires that we make two changes to our project.

The first thing that we need to do is to create our custom implementation[^1] of the `TextInputFormatter` abstract class. There's one important thing in the implementation, except for the actual parsing of data, in the constructor we need to declare which content types and encodings that we're supporting. If we were to use any other values than those API consumer uses, our `TextInputFormatter` would not qualify and therefor would not be used.

[^1]: The implementation used here is not our actual implementation, it only serves as an example of using protobuf with `TextInputFormatter`. Additional information on using [Custom formatters in ASP.NET Core Web API](https://docs.microsoft.com/en-us/aspnet/core/web-api/advanced/custom-formatters?view=aspnetcore-5.0) can be found in the official documentation.

```csharp
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Comvius.Protobuf.Api.Surveys;
using Microsoft.AspNetCore.Mvc.Formatters;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Net.Http.Headers;
using static Google.Protobuf.JsonParser;

public class ProtobufMessageTextInputFormatter: TextInputFormatter {
    public ProtobufMessageTextInputFormatter()
    {
        SupportedMediaTypes.Add(MediaTypeHeaderValue.Parse("application/json"));
        SupportedEncodings.Add(Encoding.UTF8);
        SupportedEncodings.Add(Encoding.Unicode);
    }

    public override async Task<InputFormatterResult> ReadRequestBodyAsync(InputFormatterContext context, Encoding encoding)
    {
        var httpContext = context.HttpContext;
        var logger = httpContext.RequestServices
            .GetRequiredService<ILogger<ProtobufMessageTextInputFormatter>>()

        try
        {
            using var reader = new StreamReader(httpContext.Request.Body, encoding);
            var content = await reader.ReadToEndAsync();

            var message = Default.Parse<ProtobufMessage>(content);
            return await InputFormatterResult.SuccessAsync(message);
        }
        catch (Exception e)
        {
            logger.LogWarning(e, "Unable to read request body and parse message request");
            return await InputFormatterResult.FailureAsync();
        }
    }
}
```

*The implementation is rather crude as I've yet to refine it and make it generic to work with any `IMessage` [^2], I ran out of time and had to leave it for next week.*

[^2]: Right now it only works with one type, see `Default.Parse<ProtobufMessage>(content)` where `ProtobufMessage` **is not real** and should be replaced with your type.

The second thing that needs to be done is to configure the controllers to use our `TextInputFormatter` which is done in the `Startup.cs`.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers(options =>
    {
        options.InputFormatters.Insert(0, new ProtobufMessageTextInputFormatter());
    });
}
```

An important thing to note here is that we need to prepend our `TextInputFormatter` implementation. If we were to use `.Add` instead, our implementation would not be used as there would be other implementations before ours in the list that would qualify based on the content type and encoding.

One last thing, as the consequences for if this issue would reach our production[^3] environment is rather critical, since we would essentially lose data one every call to the affected endpoints, we've added additional end-to-end integration tests[^4].

[^3]: There is no production environment just yet as we are still in the very early stages of the project, we only have our internal shared development environment (which is created automatically in our CI/CD pipeline using Terraform).

[^4]: We've had multiple issues, primarily with setup and tear down in our CI/CD environment, running integration tests where both .NET and SQL Server are used. All of these issues have forced us to de-prioritize integrations tests. But due to these serialization/deserialization issues, which we didn't foresee, we've added the necessary tests to ensure that this does not happen again.

As I was researching the issue I didn't find anything useful, no open/closed issues on the GitHub project for the nuget, no Stack Overflow threads, etc. The reason for this is, I assume, that nobody uses protobuf with .NET MVC and instead uses the GRPC implementation, which to be fair would also be a valid solution in our case but at this point we're rather invested into .NET MVC (not only for this project but as an organization) and our deadline approaches.
