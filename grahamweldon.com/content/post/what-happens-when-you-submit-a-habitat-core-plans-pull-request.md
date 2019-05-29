---
title: "What happens when you submit a Habitat core-plans pull request?"
slug: "what-happens-when-you-submit-a-habitat-core-plans-pull-request"
date: 2019-02-05T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'coreplans', 'opensource', 'community']
---

Habitat's [core-plans][core-plans] is the central repository for packages/plans maintained by a group of volunteers. These plans form the basis of pretty much everything built with Habitat. From low level libraries and tools such as GCC, glibc, openssl to high level applications like Jenkins, Artifactory, and a whole range of others. The full list can be seen in the [Github repository][core-plans].

Theres a bunch of things that happens behind the scenes of your pull request on the [Habitat core-plans repository][core-plans]. And it might help both the community and the contributors to get an understanding of whats going on when a pull request is submitted.

The checks and steps taken can be broken into two: Automated processes, and Manual processes.

### Automated Processes

A "DCO" check is started. This is a custom check that ensures your commits are signed. If they are not signed, the pull request is marked with an error, and it cannot be merged. This is a security measure, to ensure only trusted / known users are committing code. There may also be legal reasons for doing this. Remind me to check with Chef Inc. at some point to get the full details..

A ShellCheck pass is initiated to ensure that the BASH within the pull request meets the coding standards of the project. This standardises the code, so that its uniform and predictable. The Shellcheck also includes some safeguard techniques/approaches to ensure command arguments that may contain spaces are correctly quoted, etc. Simple checks to ensure great code quality.

Once these checks are passed, its up to one of the volunteer team to jump in and review your pull request.

### Manual Processes

The steps here will vary from person to person, but are generally followed in this way, with the technical details of each check perhaps varying for each member that undertakes a pull request review. For the following, this is my standard process, and it has evolved over time to ensure good quality commits coming through, good feedback to contributors, and overall a fair and easy process.

In the following examples, I'll use OpenResty as an example plan.

#### Quick scan of pull request changes

This quick scan is done to mentally check off a few items:

* Does the pull request diff look reasonable?
* Is it only addressing one plan, or one "problem" in multiple plans? Or should it be split up?
* Does it comply with all [RFCs][rfcs] in place for core-plans?
* Does it contain some testing steps?
 * Ideally these are automated
 * But a list of steps in the PR notes is good enough for me
* Is this a base plan? Do a lot of other core-plans depend on it, and what are the implications of merging this request?

Some of these questions require a decent knowledge of the full chain of plans, and their dependencies. Others are much simpler and can be checked off quickly.

#### Checkout locally

Once the quick scan is complete and looks OK, I'll merge the changes into my local clone.

I'll then fire up a (usually) clean habitat studio environment in which to test the build.

```bash
hab studio enter
DO_CHECK=1 build openresty
```

I build with `DO_CHECK=1` to ensure any checks are run as part of the build.

Does the build complete successfully? Are there tests included with the source code that can be run, that weren't?

#### Inspect built files

Does the plan ship any necessary `LICENSE` files and other errata?

If it has built libraries or binaries that are being distributed, are they correctly linked? This can be checked with a variety of tools. I like to do a **very** quick pass with `ldd` to see whats going on in the binary.

```bash
find /hab/pkgs/grahamweldon/openresty/1.13.6.2/20190204043941 -type f -executable | xargs ldd
```

This produces a somewhat messy output, but gives me a quick overview of whats going on with the included binaries.

#### Services

If the plan is a service plan, in that it starts a process under the habitat supervisor, I'll start the service and perform checks to ensure that service is running as expected.

* Does the process remain up?
* Does it open ports that it is expected to?

#### Binary plans

For simple binaries, some of the most common checks are very simple:

Is it the correct version?

```bash
# openresty -v  
nginx version: openresty/1.13.6.2
```

Can it show help output?

```bash
# openresty --help
nginx: invalid option: "-"

# openresty -help
nginx: invalid option: "e"

# openresty help
nginx: invalid option: "help"

# openresty -h
nginx version: openresty/1.13.6.2
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /hab/pkgs/rakops/openresty/1.13.6.2/20190204043941/nginx/)
  -c filename   : set configuration file (default: conf/nginx.conf)
  -g directives : set global directives out of configuration file
```

Both the successes and the failures of this command are useful to determine its functionality.

Does it perform basic functions (command line tests)

```bash
# openresty -T
```

#### Documentation

Does the readme match the [core-plans template][readme-template]?

Are there any **todo**s marked that could be removed or replaces as part of this pull request?

#### Other

There are other checks that can be done, depending on the plan, the reason for the pull request, and what is being investigated or changed as a result of that pull request. A great example of a pull request that benefited from extra testing is [this one for PHP][php-pr] which adds an extra in-php test to ensure the Libzip support is functioning correctly.

### Summary

Its not an exact science. And its not paid work. We've got some great volunteers that genuinely care about the quality of core-plans, and ensuring the best standards are maintained, while also balancing with being encouraging and open to accepting new pull requests, and growing the community.

Habitat's open source teams are awesome, and I'm super proud to be a part of the core-plans maintainers.

[core-plans]: https://github.com/habitat-sh/core-plans "Habitat core-plans repository"
[rfcs]: https://github.com/habitat-sh/core-plans-rfcs/tree/master/_RFCs "Habitat core-plans RFCs"
[readme-template]: https://github.com/habitat-sh/core-plans/blob/master/README_TEMPLATE_FOR_PLANS.md "Habitat README file template"
[php-pr]: https://github.com/habitat-sh/core-plans/pull/1946/files "Habitat pull request for PHP"