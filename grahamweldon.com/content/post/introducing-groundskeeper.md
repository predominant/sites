---
title: "Introducing Groundskeeper"
date: 2019-08-28T00:00:00+09:00
highlight: false
draft: false
tags: ['chef', 'opensource', 'community', 'habitat']
---

I've been doing fairly regular and extensive contributions to the [Habitat][habitat] [core-plans][core-plans] repository over the last couple of years. Primarily keeping packages up to date, but also contributing new ones, and helping shape the structure and format of our approach to testing all packages, to ensure quality.

One of the challenges with diverse management of open source software is keeping up to date with changes as they happen. There are a number of projects and sites around that track open source software and can provide notifications, but none offered up-to-the-second source based version information. They solutions out there are cached, sometimes behind actual releases, and were not exactly suiting my needs.

Thus, [Groundskeeper][groundskeeper] was born.

[Groundskeeper][groundskeeper] is a simple set of Shell scripts that check the [Habitat][habitat] [core-plans][core-plans] repository for all software we package, and then checks the canonical source for the lastest version. Sounds simple, right?

Wrong. Here are some of the challenges of trying to build a central software tracking system:

* Almost no-one has an API
* A release on Github doesn't always mean a "real" release
* Sometimes a tag isn't a release
* Everyone uses a different versioning standard
* Popular (GNU particularly) software is distributed and listed on a website, so it needs to be scraped
* .. the list goes on.

When you're dealing with over 600 packages, this is a complex problem.

In Groundskeeper I take a try and fail through approach (with huge help from [Steven Danna][stevendanna]) that reaches out to the canonical source for each plan/package we have, and compares the plan version against the latest detected version. The result is a list of text indicating status that we can parse and take action against:

```text
| 7zip 16.02 16.02 
> R 3.5.0 3.6.1 
- bats 0.4.0 unknown (base-plan)
```

The status here is:

* `|` Currently up to date
* `>` Difference between plan version and latest version
* `-` Unknown / Unable to determine latest version

If you check the [changelog][changelog] you can see we started at a modest 17% coverage of plans, and now we sport 73% coverage, although a large portion of that is now using a fallback mechanism that may not be exactly up to date whent he script is run.

Coverage is determined by whether or not an upstream could be contacted, and its output parsed to determine a version.

This was a super fun project to work on, and definitely helped in strengthening my skills with Shell scripting.

[habitat]: https://habitat.sh "Chef Habitat"
[core-plans]: https://github.com/habitat-sh/core-plans "Habitat core-plans repository"
[groundskeeper]: https://github.com/predominant/groundskeeper "Groundskeeper repository"
[stevendanna]: https://github.com/stevendanna "Steven Danna"
[changelog]: https://github.com/predominant/groundskeeper/blob/master/CHANGELOG.md "Groundskeeper changelog"
