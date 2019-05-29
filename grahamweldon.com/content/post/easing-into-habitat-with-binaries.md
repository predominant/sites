---
title: "Easing into Habitat with binaries"
date: 2018-10-18T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'configuration', 'development', 'migration']
---

I've posted a few times on the topic of [Habitat][habitat]. I feel its the most promising solution for software package management, and deployment available today. If I have managed to help sway you, and thus you're interested in adopting Habitat, you may find yourself faced with a relatively daunting task.

Migrating a working, functional system from one underlying layer to another is risky, potentially disruptive, and time consuming. All these reasons are why successful financial and enterprise businesses tend to have a slow rate of change.

**Solution** - Migrate just one piece at a time.

Its very possible to replace your existing binaries on your servers with Habitat packaged ones, without modifying any more of the system. This is a great "toe in the water" test to see how you like the habitat packaging, and introduce these changes one at a time.

Take [Redis][redis] for example. At [work][rakuten] we recently needed Redis v4 deployed, and we had a good collection of Redis v3 Chef cookbooks to do deployment. As part of an upgrade test, we commented out the `package redis4` line, and replaced with a few habitat commands and related bash:

```sh
# Install Habitat
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash

# Install Redis
hab pkg install core/redis

# Symlink to where the system expects Redis to be
ln -s "$(hab pkg path core/redis)/bin/redis-server" /usr/local/bin/redis-server
```

With this in place, the existing **systemd**, **upstart** or other *init*/ process supervisor can load Redis as normal, but will now be referencing the Habitat binaries.

Whats more, with this approach you can have multiple versions installed, and roll back and forth between them as you like, rather than having to deal with conflicting versions in traditional package managers.

I've found this is a great way to get people involved in the basic of Habitat, and to introduce it into the systems administration/maintenance workflow. After some time, once confidence has been gained, you can move a little further by starting to replace some services with Habitat based services. But that is a post topic for another time.

[habitat]: https://www.habitat.sh/ "Habitat home page"
[redis]: https://redis.io/ "Redis web site"
[rakuten]: https://rakuten.co.jp/ "Rakuten home page in Japan"