---
title: "Building Chef Infra on Cumulus Linux (armel)"
date: 2021-01-28T00:00:00+09:00
highlight: false
draft: false
tags: ['devops', 'chef', 'arm']
---

None of the below is possible without **heavily** leaning on work already done by the amazing [Matt Ray][mattray] ([Twitter][mattray-twitter]). He's done a ton of work around [32-bit ARM builds for Chef and Cinc][mattray-arm], and this work is only possible with his lead work.

I've recently been tasked with collaborating on a project that involves the deployment of Cumulus Linux to various datacenters, and to facilitate the automation of datacenter setup and deployment. With the existing large community and knowledge set around Chef, using it to also configure our switches makes a lot of sense. The hardware, however, is a little tricky.

Mostly the buulds scripts Matt provides work great! The only changes required were preloading a library, and sending a cumulus pull request to omnibus.

### ld.so.preload

```sh
# Run as root
echo "/usr/lib/liblog.so" > /etc/ld.so.preload 
```

### Cumulus pull request

To allow omnibus to parse OS information, the following pull request was sent over to Chef (and accepted/merged within a couple of minutes):

[Cumulus support pull request](https://github.com/chef/omnibus/pull/996/files)

Once those were in place, the build takes ~5 hours or so on the slow hardware I am using (

### Summary

Not a lot to see here. Matt has done all the hard work and deserves the praise for the ground work to get this completed.

### Hardware information

The following is a dump of the hardware information from the system I am using, which proved useful in build preparation and debugging:

```
# ---------------------------------------------
$ lscpu 
Architecture:          armv7l
Byte Order:            Little Endian
CPU(s):                2
On-line CPU(s) list:   0,1
Thread(s) per core:    1
Core(s) per socket:    2
Socket(s):             1
Model name:            ARMv7 Processor rev 0 (v7l)


# ---------------------------------------------
$ cat /proc/cpuinfo 
processor	: 0
model name	: ARMv7 Processor rev 0 (v7l)
BogoMIPS	: 1980.41
Features	: half thumb fastmult edsp tls 
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x3
CPU part	: 0xc09
CPU revision	: 0

processor	: 1
model name	: ARMv7 Processor rev 0 (v7l)
BogoMIPS	: 1990.65
Features	: half thumb fastmult edsp tls 
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x3
CPU part	: 0xc09
CPU revision	: 0

Hardware	: BRCM XGS iProc
Revision	: 0000
Serial		: 0000000000000000


# ---------------------------------------------
$ uname -a
Linux cumulus 4.1.0-cl-7-iproc #1 SMP Debian 4.1.33-1+cl3.7.14u1 (2020-11-10) armv7l GNU/Linux
```


[mattray]: https://mattray.github.io/
[mattray-twitter]: https://twitter.com/mattray
[mattray-arm]: https://mattray.github.io/arm/
