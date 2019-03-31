+++
title = "Introducing Worker"
date = "2015-11-08"
+++

Where I work we register our hours every month and to easier keep track of the
hours I began developing Worker (working name).

Since a coworker and I have been the target audience, our work schedule have
affected a lot of the implementation.

For example, we work eight hours on a normal day, and we always register the
time with hours and minutes so the difference calculation is based on this fact.
If I'd work 15 minutes overtime one day, this would be displayed as `+0.15` on
the time report.

If this seem similar to your schedule, why not give it a try? It's available at
[Google Play as open beta](https://play.google.com/apps/testing/me.raatiniemi.worker),
feedback is always appreciated.

The implementation that's specific to our schedule will become configurable. I
just haven't had a reason to prioritize this since the application have been in
closed alpha since until recently.

The application requires that the device is running Android 8.1 or later.
