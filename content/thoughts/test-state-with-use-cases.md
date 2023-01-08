+++
title = "Setup test state with use cases"
date = "2019-12-09"
+++

Setting up state when writing tests can be a cumbersome tasks, especially if the
system under test requires a lot of different components. For the last couple of
months I've been using a new approach for my projects.

In Worker, I use several use cases to represent the core domain logic,
e.g. in order to clock in a project the `ClockIn` use case is used. These use
cases ensures that the constraints for the input data are met and handle the
communication with the other necessary components, e.g. repositories.

Other than performing the core domain logic, these use cases can also be used to
set up the necessary initial state when running tests.

The following example is actual code taken from one of the view model tests, and
the purpose of the code is to toggle the value of the `isRegistered`-property
for several `TimeInterval`s. There's a lot of setup code in this example and
that's kind of the problem, it's very difficult to get a good overview of what's
going on.

The first thing that we do is set up the data in the repository. This requires us
to first add a `NewTimeInterval`[^1] and then update it with a `stop` value,
i.e. clock out. Next up is to build the values we are going to use in the test
with the same values that we've used when setting up the repository[^2]. The
last thing we need to do is set up the expected repository state.

```kotlin
@Test
fun `toggle registered state for selected item`() {
    repository.add(
        newTimeInterval(android) {
            start = Milliseconds(1)
        }
    ).also {
        repository.update(it.clockOut(stop = Milliseconds(2)))
    }
    val timeInterval = timeInterval(android.id) { builder ->
        builder.id = TimeIntervalId(1)
        builder.start = Milliseconds(1)
        builder.stop = Milliseconds(2)
    }
    val expected = listOf(
        timeInterval(timeInterval) { builder ->
            builder.isRegistered = true
        }
    )

    vm.consume(TimeReportLongPressAction.LongPressItem(timeInterval))
    vm.toggleRegisteredStateForSelectedItems()

    val actual = repository.findAll(android, Milliseconds.empty)
    assertEquals(expected, actual)
}
```

If we take a look at how we can set up the same state using use cases. There are
two use cases involved in the data setup, `ClockIn` and `ClockOut`. Both will
validate the expected state against the repository, i.e. in order to be allowed
to call `ClockOut` we first need to call `ClockIn`.

The `groupByWeek` is a free function that's primarily used to simplify the test
assertion along with the `FindTimeReportWeeks` use case, but we can argue that
since the rest of the view model is working with `TimeReportWeek`s we should be
consistent.

```kotlin
@Test
fun `toggle registered state for selected items`() {
    val startOfDay = setToStartOfDay(Date())
    clockIn(android, startOfDay)
    val timeInterval = clockOut(android, startOfDay + 4.hours)
    val expected = groupByWeek(
        listOf(
            timeInterval(timeInterval) { builder ->
                builder.isRegistered = true
            }
        )
    )

    vm.consume(TimeReportLongPressAction.LongPressItem(timeInterval))
    vm.toggleRegisteredStateForSelectedItems()

    val actual = findTimeReportWeeks(
        android,
        LoadRange(LoadPosition(0), LoadSize(10))
    )
    assertEquals(expected, actual)
}
```

There's still a lot of code to go through, however I think the intention of the
code is a lot clearer which is important for maintainability. The benefits of
this approach, as I see it, is as follows:

1. We improve readability by hiding unnecessary technical details and reducing
   the necessary code.
2. We reduce the risk of needing to change anything since we use higher level
   concepts, e.g. if the repository interface change accepted types.
3. We ensure that the test operate using valid state (While migrating I noticed
   multiple scenarios that was testing with invalid state due to laziness).
4. We use a similar path of execution as the user would, i.e. go through use
   cases instead of direct access to the repositories.

As with everything there are downsides as well. The one that I've encountered is
that we require more code in order to configure the necessary dependencies[^3].

[^1]: The repository only allows for adding `NewTimeInterval` which by design do
      not have a `stop` property since all new time intervals are active.
[^2]: The `update` method do return a value, but it's a `TimeInterval?` which
      would require us to unwrap it before we can use it, and I'd prefer not to
      use `!`, even in test code.
[^3]: This can be mitigated by using a dependency injection framework, i.e. I
      use [Koin](https://insert-koin.io/) and have a separate test module with
      the necessary in-memory dependencies.
