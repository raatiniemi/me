+++
title = "Represent object state using sealed class"
date = "2019-08-05"
+++

In my time tracking application, I have a `TimeInterval`-class, which represents
an interval in time using two properties, `start` and `stop`.

The application allows the user to start a new time tracking session and then
stop the session. Which means that this class needs to support both states.

As the application was originally written in Java, the state is inferred from
the value of the `stop` property, i.e. if the value is zero the time interval is
active [^1].

```
data class TimeInterval(val start: Long, val stop: Long)

val active = TimeInterval(start = 1, stop = 0)
val inactive = TimeInterval(start = 1, stop = 2)
```

Using this approach to represent the different states works, but it require that
each developer working with the code knows about it [^2]. And, the code do not
in any way communicate this to the developer, other than the usage pattern.

After migrating the entire application to Kotlin, and getting inspired by
different articles, books and podcasts on functional programming, I decided to
improve this by using a `sealed class` with each state represented by a
different class.

```
sealed class TimeInterval {
  data class Active(val start: Long): TimeInterval()

  data class Inactive(val start: Long, val stop: Long): TimeInterval()
}

val active = TimeInterval.Active(start = 1)
val inactive = TimeInterval.Inactive(start = 1, stop = 2)
```

The active state now clearly indicates that the value for the `stop` property
should not be used. The object state, as persisted in the database, is now only
an implementation detail that never goes beyond the repository boundary.

Another benefit of representing each state as a separate type is that we can
encode more domain knowledge into the type system and have the compiler help
enforce this logic.

As a simple example, the active state needs to be able to transition from an
active state to an inactive state, i.e. a `clockOut`-method.

```
if (timeInterval !is TimeInterval.Active) {
  throw IllegalStateException()
}

timeInterval.clockOut(Date())
```

Or, if we need to perform some calculations based on the value of `start` and
`stop`, we can cache the value using a `by lazy` implementation for the inactive
state since the value will not change. The value for the active state will still
be calculated for each separate call.

[^1]: The real `TimeInterval`-class is a bit more complicated, but it has been simplified here for the sake of this example.
[^2]: This is often referred to as [Tribal knowledge](https://en.wikipedia.org/wiki/Tribal_knowledge).
