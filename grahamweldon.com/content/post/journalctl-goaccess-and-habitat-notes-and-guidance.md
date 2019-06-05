---
title: journalctl, goaccess and Habitat notes and guidance
slug: "journalctl-goaccess-and-habitat-notes-and-guidance"
date: 2019-05-29T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'journalctl', 'goaccess', 'logging', 'administration', 'systemd', 'caddy']
---

You've got a modern server, its got systemd, journalctl, and you have Habitat supervisor running a Caddy webserver. What an amazing setup of great technology! Gluing these pieces together is easy, but I've found a couple of places where I wish documentation had been better. This post serves as a notice to myself and anyone else that is interested in how to get [goaccess](https://goaccess.io/ "Goaccess web site") working in this new modern ecosystem.

## Install goaccess

Simple step. I chose to install this directly from the [Habitat core plans](https://github.com/habitat-sh/core-plans "Habitat core plans repository") like so:

```shell
hab pkg install core/goaccess --binlink
```

Ideally **never** run a core plan directly. But since this is a binary plan, its not a problem.

## Caddy logging

Caddy by default, logs in a simple format. Here is what you will see with a default install with default logging format for a site request:

```text
111.111.111.111 - - [06/Mar/2019:09:33:28 +0000] "GET / HTTP/1.1" 200 4476
```

Pretty simple. Add to this, the Habitat supervisor service name and group information:

```text
site-grahamweldon.default(O): 111.111.111.111 - - [06/Mar/2019:09:33:28 +0000] "GET / HTTP/1.1" 200 4476
```

And of course, there is also the journald information prefixed to the front to handle date lines and user information etc:

```text
Mar 06 09:33:28 web0 hab[1072]: site-grahamweldon.default(O): 178.128.58.99 - - [06/Mar/2019:09:33:28 +0000] "GET / HTTP/1.1" 200 4476
```

To get the log output in a more common format, the following directive in your `Caddyfile` should be created:

```text
log / stdout "{combined}"
```

Full details on the various log options and configuration can be found on the [Caddyfile log documentation](https://caddyserver.com/docs/log "Caddyfile documentation for logging").

The result is a log entry lookging like the following:

```text
May 28 23:45:00 web0 hab[1072]: site-grahamweldon.default(O): 178.128.58.99 - - [28/May/2019:23:45:00 +0000] "GET / HTTP/1.1" 200 4788 "-" "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/98 Safari/537.4 (StatusCake)"
```

Changing the format to `"{combined}"` will result in the common "Apache / Nginx" format that we're used to seeing. And this is much more ingestible by goaccess, as it has common format as one of its defaults.

Note, however, that we still have habitat supervisor and journald information tacked on to the front of each line. We'll need to consider this when instructing goaccess how to read our logs.

## Running goaccess and configuration

Fire up a journalctl tail with goaccess:

```text
journalctl -f -u hab-sup | \
  grep --line-buffered --color=never "site-grahamweldon" | \
  goaccess -f -
```

Note the `grep` in the middle is just to filter out a single service from the habitat supervisor, as I have multiple web logs coming through various habitat-supervised services.

With regards to configuration, I'm taking the easy way out. I want all the access log information, without the superfluous habitat/journald data.

Choose the `NCSA Combined Log Format` by pressing `[SPACE]`. Then press `c` to customise the log format. You want to add some fields at the beginning to skip. The final log format should be:

```text
%^ %^ %^ %^ %^: %^: %h %^[%d:%t %^] "%r" %s %b "%R" "%u"
```

Press `[ENTER]` twice, and you'll be presented with the console UI for goaccess. Sample below:

![goaccess screenshot with sample web activity displayed](/uploads/2019/05/29/goaccess_screenshot.png)