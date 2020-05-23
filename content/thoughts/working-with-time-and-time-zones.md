+++
title = "Working with time and time zones"
date = "2020-05-23"
draft = true
+++

Worker, my primary side project, is a time tracking application which
I've been working on since the early 2015. During this time I've had
to learn, the hard way, that working with time and especially time
zones is really difficult.

Today, I've been working on an improvement where if the user clock in
on one day and clock out on the next day, we'll create separate two
time intervals instead just one. The need for the two separate time
intervals is to ensure that the time report feature the time correctly
over multiple days.

This is certainly an edge case (at least for how I use the application),
but it has been in the back log for at least a couple of years. My, very
naive, thinking was to check if the time interval start and stop was on
different days and then split them around midnight.

```kotlin
fun clockOut(active: TimeInterval.Active, stop: Milliseconds) {
    if (isOnSameDay(active.start, stop)) {
        save(active, stop)
        return
    }

    val startOfNextDay = calculateStartOfNextDay(active)
    save(active, startOfNextDay - 1.milliseconds)

    val timeInterval = TimeInterval.Active(
        start = startOfNextDay
    )
    save(timeInterval, stop)
}
```

The example above is only a rough outline of the actual implementation
from the `ClockOut` use case, some parts have been removed to improve
readability. *One important thing to note here is that `Milliseconds`
represents a UNIX timestamp, which means that it's always in UTC.*

During the implementation I've had a lot of issues, all seem to have the
same root cause, expecting a value in UTC while actually using a value
in local time or the inverse.

As an example, one of the first issues I ran into was that the use case
only produced one time interval when two was expected, the test input
data I was using was `23:30` for start and `00:30` for stop. But since
these values was calculated for the current day they were also
calculated in my local time, i.e. `Europe/Stockholm` and +02:00, and
`isOnSameDay` was only comparing the timestamps as they are in UTC (i.e.
start was converted to `21:30` and stop was `22:30`).

It really feels like the more time I spend working with time and time
zones, the more issues and edge cases I see. I know that I'm not alone
here, but there's certainly a difference in reading about all of the
issues other people have and experiencing them first hand.

One thing I've also noted is that I don't store enough information along
with the `TimeInterval`. Both `start` and `stop` are represented using
`Milliseconds`, i.e. only a UNIX timestamp, which should work fine for
most use cases as long as the device remain in the same time zone.
