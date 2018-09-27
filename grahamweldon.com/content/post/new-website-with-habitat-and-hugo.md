---
title: New website with Habitat and Hugo
date: 2018-09-11T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'web', 'development', 'hugo']
---

I recently did a complete overhaul of [my website](/).

The previous version was built with [CakePHP][cakephp], as a demonstration as I was working closed with CakePHP. Times change, and so do trends, and I try to keep ahead of it. Static site generators are gaining more popularity. I've been eyeing [Hugo][hugo] for some time, and decided it was time to refresh my website and try some new deployment options while I was at it.

## Technology selection

| Technology | Old | New | Reason |
| :--- | :--- | :--- | :--- |
| Site | [CakePHP][cakephp] | [Hugo][hugo] | Switch to static site generation |
| Web Server | [Nginx][nginx] | [Caddy][caddy] | Try new tech, Auto SSL |
| SSL | None | [Lets Encrypt][letsencrypt] | Secure everything, for free! |
| Packaging | None/[Composer][composer] | [Habitat][habitat] | Write once, deploy anywhere |
| Deployment | Python/[Fabric][fabric] | [Terraform][terraform] | Combine infrastructure and app together, single command deploy |

## Old architecture

The previous server was a simple setup. Nginx as a web server, handing off to php-fpm for PHP processing. Nginx handled all ingress, serving static files and PHP files. This server was a little busy, hosting 18 separate websites off the single Nginx instance. It operated quite well, and over the last 8 years has managed to host some popular gaming sites pulling tens of thousands of hits per day.

The structure was as follows:

<div class="mermaid">
graph LR
  User --> |SSL| Firewall

  Firewall --> |SSL| Nginx

  Nginx --> |Unix Socket| PHP-FPM_1
  Nginx --> |Unix Socket| PHP-FPM_2
  Nginx --> |Unix Socket| PHP-FPM_n
  Nginx --> |Filesystem| Static
</div>

Each site that used PHP had its own PHP-FPM pool. This meant hundreds of PHP processes were running, each with different configuration based on the site's specific requirements.

## New architecture

The new structure is a little different, separating the SSL offload separately from the web server allocated to a single site.

Each site is packaged with a web server, so the "contract" for a website is to provide a port on which I can communicate via  regular unencrypted HTTP from the load balancer.

<div class="mermaid">
graph LR
  User --> |SSL| Firewall
  Firewall --> |SSL| Caddy["Load balancer (Caddy)"]
  Caddy --> |HTTP| Site1["Website 1 (Caddy)"]
  Caddy --> |HTTP| Site2["Website 2 (Caddy)"]
  Caddy --> |HTTP| Site3["Website 3 (Caddy)"]
</div>

This setup allows for the consolidation of SSL offloading in a single process for all hosted sites. The configuration and packaging of that load balancer component is a single habitat package. Thus, I can deploy this load balancer package multiple times on many nodes and guarantee the setup is replicated identically across nodes.

## Load balancer / SSL handling

Doing the load balancer / SSL offloading with Caddy means automatic HTTP/2 support, and SSL encryption with Lets Encrypt. This was a huge win. You can see [the package on Habitat Builder here][lb-package].

## Website packaging

I'll discuss more of [Hugo][hugo] in another post. I packaged each website as a habitat package as well. This ensures that each site has its own web server packaged with it, and that its configuration is managed separately from each other site. While this initially might seem like a lot of duplication of processes and server configuration, its actually another huge win to know that each site is standalone, and changes to one will not affect another. You can see [the package on Habitat Builder here][grahamweldon-package] for my personal site.

## Habitat wins

Now that I have each of these layers isolated as Habitat packages, and they're running on the Habitat supervisor, launching more of them is dead simple. I can terraform another server for the backends, or launch a secondary service as required, and it will join the Habitat supervisor ring, and result in addition to the load balancer due to [the use of Habitat's helpers in the load balancer configuration][lb-config-1].

I'm also able to export the packages to multiple runtime formats, including but not limited to: Docker, tarball, helm/Kubernetes etc. I'm freed from a singular operating system, and from any dependencies that might need to be managed as a result.

## Conclusion

Overall I'm happy with Hugo and the move to a static site, over the requirement for PHP on the backend. I feel like this is a good move for the future, despite the learning curve of Hugo (seriously, its super complicated, and there is a lot to it).

Habitat is taking over my life, and I love it. I can focus on building applications, and almost completely remove the need to consider deployment targets. As long as I can build my application and produce an artifact, it will run on my virtual machine, container system, or bare metal.. Thats truly liberating.


[hugo]: https://gohugo.io/
[cakephp]: https://cakephp.org
[nginx]: https://www.nginx.com/
[caddy]: https://caddyserver.com/
[letsencrypt]: https://letsencrypt.org/
[habitat]: https://www.habitat.sh/
[composer]: https://getcomposer.org/
[fabric]: http://www.fabfile.org/
[terraform]: https://www.terraform.io/
[lb-package]: https://bldr.habitat.sh/#/pkgs/grahamweldon/site-loadbalancer
[grahamweldon-package]: https://bldr.habitat.sh/#/pkgs/grahamweldon/site-grahamweldon
[lb-config-1]: https://github.com/predominant/sites/commit/839ca2fb3d61a8c4464783f7b4118e08c2b9376f#diff-dbb06892188adedff6c62042513e966fR19
