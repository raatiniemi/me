+++
title = "A lesson in nullability with PagedList"
date = "2019-11-22"
+++

In the last couple of days I published a new release of Worker to internal
tester and with this release I saw a rise of crashes reported to Firebase
caused by a `NullPointerException`.

The application is written in Kotlin (converted of the last year from Java), and
I've been careful regarding the use of optional/nullable values. So, the rise of
crashes was very confusing and I've gone over the related code multiple times
without finding any red flags.

The crashes occurred when the time report view[^1] had been opened for one
minute which caused me to believe that there were some issue with the "refresh
active time interval"-feature.

In this view I populate a `PagedListAdapter` using a `PagedList<TimeReportWeek>`
property from the view model. And to refresh active time interval I take the
current list from the adapter and iterate though the list to find if any loaded
time intervals is active, the code for this is as follows (located in the view
model).

```kotlin
private fun findActivePosition(weeks: List<TimeReportWeek>): Int? {
    return weeks.filter(::containsActiveDay)
        .map(weeks::indexOf)
        .firstOrNull()
}

private fun containsActiveDay(week: TimeReportWeek): Boolean {
    return week.days.firstOrNull { it is TimeReportDay.Active } != null
}
```

*Note that I'm declaring that the `weeks` argument is a `List<TimeReportWeek>`,
but under the hood it's actually a `PagedList<TimeReportWeek>`.*

Since the release I've been trying to figure out what could cause the crashes,
without being able to successfully reproduce the crash in a debug environment.
And, this morning by chance I was tweaking the `PagedList` configuration[^2] in
order to see if I could optimize the load times and this caused the application
to crash with a `NullPointerException`.

After attaching a debugger I noticed that the application crashed when we
attempted to access the `days` property because `week` is `null`. And, for a few
seconds I was confused as the list should not allow for `null` values by the
type system. But then it hit me, using a `PagedList` when placeholders are
enabled will produce `null` values for not yet loaded items.

[^1]: An infinite scrolling list of time intervals grouped by work week.
[^2]: How the infinite scroll should load items, how many to cache, etc.
