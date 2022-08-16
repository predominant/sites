---
title: "Adding network information to your MOTD for Raspberry Pi"
date: 2022-08-17T00:00:00+09:00
highlight: false
draft: false
tags: ['opensource', 'raspberry', 'rpi', 'raspberrypi', 'linux']
---

Today I wanted to setup my various raspberry pi machines to notify me of their network detail on boot. I have recently purchased a very small 10" 1080p monitor that I can connect to each of the nodes to view boot information.

The motive for this was to see network details after DHCP had completed, and view network information on the boot screen without a login. This would allow me to view details at a glance, and access machines with information directly from the boot screen.

The first step was to provide a dynamic input to the MOTD (Message of the day) system.

So I created a new file at `/etc/update-motd.d/20-networking`

```sh
touch /etc/update-motd.d/20-networking
chmod +x /etc/update-motd.d/20-networking
```

Note the `chmod` command here. Thats very important to ensure your script can run.

Edit the file, and provide the following content:

```sh
#!/bin/sh
echo "IP Information:"
if ! test -f /tmp/firstrun; then
  touch /tmp/firstrun
  sleep 20
fi
ifconfig | grep "inet \|ether "
```

The next step is to create a job that deletes the temporary file created inside this script.

```sh
touch /etc/cron.d/network-firstrun
```

Create the file and then edit it with this content:

```sh
@restart root rm -f /tmp/firstrun
```

Reboot your machine, and the initial boot will take 20 seconds more than usual. You can tune the `sleep 20` value to something that works for your hardware and network.

BEHOLD! Your ipv4 information is now available on your boot screen without a login required. You can use this with a console monitor, or an external screen, to view your IPv4 IP Address and MAC information without requiring a login. This is going to save me lots of time in expanding my cluster from 32 to 64 nodes, as the most frustrating thing is determining MAC addresses to populate in the DHCP server to give a reasonable IP allocation.
