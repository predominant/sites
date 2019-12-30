---
title: "Habitat/Biome Census Viewer"
date: 2019-12-30T00:00:00+09:00
highlight: false
draft: false
tags: ['chef', 'opensource', 'community', 'habitat', 'biome', 'ui']
---

I've been using [Chef's Habitat(tm)][habitat] and the community distribution "[Biome][biome]" for a while now. I love the systems, and the community. However, the tools surrounding its usage have not been developed much in the way of graphical systems to aid administration.

Thats all changing!

I've worked for a couple of months on a prototype/alpha administrative viewer for the Habitat/Biome. 

![Census Viewer Screenshot](/uploads/2019/12/30/Screen Shot 2019-12-30 at 13.51.58.png)

The census viewer comes in 2 parts:

1. The primary web interface
1. The census proxy

The proxy is required to bypass CORS restrictions and permit the single page application (web interface) to connect without issues.

Simply run the proxy on one of your Habitat/Biome supervisor servers, and then launch the viewer:

```bash
hab svc load predominant/census-proxy
hab svc load prdominant/census-viewer
```

By default, the proxy loads on port `5555`. The viewer loads on port `80`.

If you need to change the port of either, you can do so with configuration. For example, this is how the port can be changed for the viewer package:

```bash
echo 'port=5556' | hab config apply census-viewer.default $(date +%s)
```

Its a little rough around the edges, its view-only, and theres many more improvements that could be made.

if you're interested in contributing, checkout the [repository on Github][repo] and feel free to submit pull requests or issues as you see them!

[habitat]: https://habitat.sh "Chef Habitat"
[biome]: https://biome.sh "Biome"
[repo]: https://github.com/predominant/Biome-Census-Viewer "Census viewer repository"
