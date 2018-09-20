---
title: Building tests for Habitat
date: 2018-09-20T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'testing', 'deployment', 'bash']
---

I've been contributing to [Habitat][habitat] for [a little while now][habitat-contributors]. Mostly in the capacity of contributions to [core-plans][core-plans], but occasionally some changes to the [on-premise-builder][on-prem-builder] and the [Habitat project][habitat-repo] itself. I've posted about my reasons for preferring Habitat [previously][post-archive], today I want to focus on the evolution of my testing for Habitat.

## Initial testing, no automation

The initial testing is similar to what all developers would currently be doing as they engage in Habitat day to day:

* Build a plan
* Install the package
* Test binaries
* Load the service (if its a service package)
* Test the service
 * Network ports
 * Process checks

This is all manual, using the command line.

Over time, I began to [include these testing steps into pull requests][testing-1] to make it simpler for reviewers to confirm a change is good, and doesn't adversely affect the package.

* [Github Pull-Request with initial testing/validation steps][testing-1]

## The start of automated testing

The testing steps above were a huge step. Given there was nothing previously, I was getting some great comments on pull requests for including validation/testing steps.

Following this, I wanted a faster and better way to check for services that had network connections open. One that I was using heavily was the [Consul][consul] [plan][consul-plan]. Consul opens a number of ports, and testing them manually as well as keeping up to date with each Consul release was becoming tedious.

I embarked on the creation of [a simple shell script][testing-2] that could handle the testing, and included some basic utilities to handle network testing. Again, a huge step forward in terms of being able to validate the build.

* [Github Pull-Request with first automated testing script][testing-2]

The core of this comes down to a shell function called `test_listen`:

```sh
test_listen() {
  local proto="-z"
  if [ "${1}" == "udp" ]; then
    proto="-u"
  fi
  local wait=${3:-3}
  nc "${proto}" -w"${wait}" 127.0.0.1 "${2}"
  test_value $? 0
  echo " ... Listening on ${1}/${2}"
}
```

`test_listen` takes 3 parameters:

1. **Protocol** (`tcp` or `udp`) (required)
1. **Port Number** (required)
1. **Wait Time** (optional, default=`3`)

With this function available, the testing for Consul became:

```sh
test_listen tcp 8300
test_listen tcp 8301
test_listen tcp 8302
test_listen tcp 8500
test_listen tcp 8600
test_listen udp 8301
test_listen udp 8302
test_listen udp 8600
```

The output of the test would print `FAIL` or `Pass` based on the port listening status.

Simple, effective. But with so many plans already in the [core-plans][core-plans] repository, it needed some improvement.

## Testing today

As of today, I've made further improvements, both with the help of reviewers and contributors on Github, as well as personally. Testing a plan now has a standard-ish approach (one thats accepted / well reviewed), and is growing in adoption.

The new testing consists of a `tests/` directory containing at minimum a `test.sh` shell file that drives the tests, and a `test.bats` primary [BATS][bats] list of tests.

* [Github Pull-Request with standardised testing][testing-3]

```sh
#!/bin/sh
TESTDIR="$(dirname "${0}")"
PLANDIR="$(dirname "${TESTDIR}")"
SKIPBUILD=${SKIPBUILD:-0}

hab pkg install --binlink core/bats
source "${PLANDIR}/plan.sh"
if [ "${SKIPBUILD}" -eq 0 ]; then
  set -e
  pushd "${PLANDIR}" > /dev/null
  build
  source results/last_build.env
  hab pkg install --binlink --force "results/${pkg_artifact}"
  popd > /dev/null
  set +e
fi

bats "${TESTDIR}/test.bats"
```

The above `test.sh` is completely generic. In fact after deploying a number of tests across various plans, I've found that I can almost always copy and paste this script around as needed. Sounds good? I'd rather not be duplicating this `test.sh` file hundreds of times, and its annoying that I have to change a couple of lines to load a service is a service exists. A single, central, standard way of testing is much more desirable.

## The future?

I've submitted a [pull request][build-test-pr] that centralises the testing scripts, and allows a minimum of code duplication, while still maintaining flexibility. It also models the way the `build` process works in Habitat currently, providing sensible defaults, and allowing callback overrides and customisation.

This pull request will allow users to enter into a Habitat studio, and quickly test any package like so:

```sh
hab studio enter
build-test nginx
```

Thats it.

## Wrap-up

Here's hoping the pull request is reviewed and included into the Studio moving forward.

I think overall i'm a slow adopter of testing. But in the last 5 years or so, its become critical for the delivery of automated deployment systems and release mechanisms.

Automation can be amazing. It helps reduce your workload, it helps get those releases out to customers faster. But if you can't validate or confirm your changes, what are you really pushing out to production?

Test your software.

![Just do it](/uploads/2018/09/20/shia-do-it.gif)

[habitat]: https://www.habitat.sh/
[habitat-contributors]: https://github.com/habitat-sh/core-plans/graphs/contributors
[core-plans]: https://github.com/habitat-sh/core-plans
[on-prem-builder]: https://github.com/habitat-sh/on-prem-builder
[habitat-repo]: https://github.com/habitat-sh/habitat
[post-archive]: /post
[testing-1]: https://github.com/habitat-sh/core-plans/pull/1644
[testing-2]: https://github.com/habitat-sh/core-plans/pull/1741/files
[consul]: https://www.consul.io/
[consul-plan]: https://github.com/habitat-sh/core-plans/tree/master/consul
[bats]: https://github.com/sstephenson/bats
[testing-3]: https://github.com/habitat-sh/core-plans/pull/1858/files
[build-test-pr]: https://github.com/habitat-sh/habitat/pull/5605