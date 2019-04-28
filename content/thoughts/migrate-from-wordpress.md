+++
title = "Migrate from WordPress"
date = "2019-04-28"
+++

For a few months now, I've been thinking that it might be time to migrate away
from WordPress.

The main reasons behind my thinking is that the platform feels overkill for what
I've done with the site, which poses a potential and unnecessary security risk,
and I wanted to use something simpler.

I did have a few requirements for my replacement.

* Allow for automated deployments using GitLab CI.
* Content should be written in a simple format, preferably markdown.

After spending some time searching for alternatives, I decided to go with
[Hugo](https://gohugo.io/).

So, a few weeks ago, at the beginning of April, I exported the few posts I've
managed to write and converted them into markdown, choose a theme for the site,
and [configured the automated deployment](https://grh.am/2018/deploying-a-hugo-static-site-using-gitlab-ci-cd-and-ssh/).
