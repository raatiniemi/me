+++
title = "Linker: A Rust story?"
date = "2021-05-22"
+++

For the last couple of years I've been building, and rebuilding, a simple test
application called [linker](https://gitlab.com/rahome/linker). And, now during
the last month I've rewritten it from JVM/Kotlin to Rust to compare potential
benefits to each approach.

The primary purpose of the application is simple, traverse and index a *source*
directory and compare the index against one or more *target* directories to see
which of the items from the source directory are not present in either of the
target directories. Based on the configuration, it can also create the missing
symbolic links from one of the target directories back to the source directory.

## History

The application have already been through a couple of rewrites, the first
version was written in [golang](https://golang.org/) (back in '14 or '15).
Second version was in [PHP](https://php.net/), might be an odd choice, but it
still was my primary language at the time. The third iteration was in Java,
which was later migrated into [Kotlin](https://kotlinlang.org/).

And, now I've rewritten it in [Rust](https://www.rust-lang.org/), the primary
reason is to attempt to reduce size, both while running and "on disk". One
added bonus is that I get to try Rust with a more realistic use case. This is
my first real world exposure to Rust, which probably can be seen in my naive
implementation.

## Containers

Since the JVM/Java iterations, the deployment has been done via a container.
Working with containers there are usually metrics that are of interest (*there
are certainly a lot more things to measure, but these are my current focus*):

1. Size of the build container, used when building the app in a CI/CD pipeline.
2. Size of the runtime container, both base image and application.

These metrics are collected using the `docker images` command on the host machine.

*Please note, that these metrics are not meant to be generalisations of JVM vs
Rust, but only the findings from my specific use case.*

### Build containers

The containers used in the CI/CD pipeline for building and testing the
application are:

| Purpose | Name | Size |
| :--- | :--- | ---: |
| Build and test JVM of application | gradle:6.7.0-jdk15 | 790MB |
| Build Rust of application | rust:slim-buster | 621MB |
| Test Rust of application | rustlang/rust:nightly-slim | 1.07GB |
| ~~Build Rust of application~~[^1] | rust:alpine | 700MB |
| ~~Test Rust of application~~[^1] | rustlang/rust:nightly | 1.69GB |

As we can see, the Rust pipeline requires us to use two separate containers.
However, this is most likely only a temporary issue and won't be necessary once
support for test coverage is available in stable Rust.

### Runtime containers

The containers used to run the actual application, including base images, are:

| Purpose | Name | Size |
| :--- | :--- | ---: |
| JVM application base image | openjdk:15-alpine | 343MB |
| JVM application | registry.gitlab.com/rahome/linker | 350MB |
| Rust application base image | debian:buster-slim | 69.3MB |
| Rust application | registry.gitlab.com/rahome/rust-linker | 76.1MB |
| ~~Rust application base image~~[^1] | alpine:latest | 5.61MB |
| ~~Rust application (alpine)~~[^1] | registry.gitlab.com/rahome/rust-linker | 11.9MB |

As we can see, the actual applications regardless of runtime are similar in
size, however the base image used for the JVM application is significantly
larger. *I know that a JDK image might not be optimal, but I've not found a
better image available.*

## Runtime characteristics

When it comes to runtime characteristics there are two metrics that I'd like to
focus on, these are:

1. Execution time.
2. Memory consumption.

These metrics are collected by running the application with `time` while
running `docker stats` in a separate window.

| Variant | Execution time | Memory consumption (peak) |
| --- | :--- | ---: |
| JVM | 8 seconds | ~400MB |
| Rust (slim) | 9 seconds | ~75MB |
| ~~Rust (alpine)~~[^1] | 1 minute and 10 seconds | ~80MB |

As we can see there is a clear difference between the variants on both
execution time and memory consumption. While developing the applications I've
not done anything to improve the performance, i.e. both applications are
essentially single threaded. 

However, when I ran the JVM variant I did see some activity on multiple
threads, this leads me to believe that either the JVM or Kotlin stdlib is
performing some optimizations (not necessarily data parallelism but perhaps
increased efficiency with scheduling the work on different threads).

## Next step

Now that I have the application working on two different runtimes I'm going to
do some additional investigations. To start with I'd like to see if I can
improve the execution time for the Rust application by performing certain tasks
in parallel. But first, it's probably a good idea to implement some kind of
tracing in the application to expose the actual bottlenecks before implementing
any kind of performance improvement[^2].

## Conclusions

I'm a bit disappointed regarding the execution time of the Rust variant, but in
hindsight it's what I should have expected, as it is single threaded and a
larger data set. The size of the runtime container and the memory consumption
are very appealing as the JVM variant feels a bit bloated. The issue with the
execution time should be solvable with some data parallelism.

As with most people coming to Rust, the borrow checker really caused some
headaches but after a few days I got used to it, at least to some degree. It
did cause me some issues later on, but only when I either did not know how to
implement the thing I wanted, was tired or just lazy. But in the end, it's an
excellent companion to have.

The language is not that different from what I'm used to, sure the syntax is a
bit different but overall it was not that big of a hurdle, and it allowed me to
use familiar functional concepts to ease the implementation.

[^1]: Using the alpine variant for Rust caused runtime performance issues,
      these issues was resolved by migrating to the slim variant (which is
      detailed in the [tracing article for linker](../linker-rust-tracing/)).
[^2]: I've gone through some work to improve the performance of the
      application, which I've written about in a separate article regarding
      [tracing a rust application](../linker-rust-tracing/).
