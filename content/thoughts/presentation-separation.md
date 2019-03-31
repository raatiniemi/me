+++
title = "Presentation separation"
date = "2016-08-13"
+++

In [Worker](https://github.com/raatiniemi/worker), the presentation uses a
variation of the [MVP](https://en.wikipedia.org/wiki/Model-view-presenter)
paradigm, and separation is done via component layer, i.e. views, models, and
presenters all have their own package.

With additional screens and increasing complexity this will quickly become
difficult to maintain. Also, it’s difficult to get a good overview of the code
related to each screen.

Since I tend to think more of screens or modules rather than component, at least
on a higher level, a screen based separation might both be easier to maintain
and reason about. However, the individual screens should still be separated by
component layer because it’ll ease the separation of concerns.

Within the presentation there are also base or global components. And, these
should be separated by component layer.

One difference between these global components and the components related to a
specific screen is their intended usage.

The global components should have minimum dependencies between them, aside from
either composition or inheritance. This will allow the components to be
separated by type, i.e. activities, fragments, widgets, etc. can be separated
into different packages. This will allow for a better component overview.

The screen specific components on the other hand should allow for some
dependencies within the boundaries of the component layer, e.g. an activity can
share constants with the fragments without the need to expose them to the
outside world. In other words, screen specific components should not be
separated by type, within the component layer.

The basic structure for the presentation package should look something similar
to this:

```
presentation
  model
  presenter
  screen
    model
    presenter
    view
  view
    activity
    adapter
    fragment
    widget
```
