---
title: "Habitatとは何ですか"
date: 2018-08-07T00:00:00+09:00
highlight: false
draft: true
tags: ['habitat', 'deployment']
---

<img src="/uploads/2018/08/07/habitat_400x400.jpg" class="right"/>

最初のリリースから[Habitat][habitat]を使用しています。 約2年。 しかし、それは何ですか

Habitatには3つの主な機能があります:

* アプリケーションビルドは移植可能になる!
* ネットワーク化されたとクラスタ認識
* デプロイメントマネージャー

These are all HUGE for any application developer. But lets take a look one at a time.

## 1. Portable application builds

What do I mean by this? Habitat's build and run environment is extremely minimal. To run an application the only real requirement is that you have a Linux kernel 2.6.32 or later on your host environment (It also works on [windows][habitat-windows]). If you're running a [go][go] binary, which is self-contained. This means your deployment environment is super small. In the case of a java application, you'll need the JRE, plus its dependencies, which are all tracked via Habitat's package dependency system.

No need to deploy a full OS packed with things you don't use. As you deploy an application, it pulls in the signed and verified dependencies that it needs. The result is a minimal OS, and all your application's dependencies belong to your application.

Using this mechanism, gone are the days of testing if an environment is ready to run your application. Because your app specifies the dependencies it needs, you guarantee they are pulled in on deployment.

## 2. Networked, cluster-aware process supervisor

There are many process supervisors that you are probably familiar with. Systemd, god, runit, supervisord, etc. The list of these is long. What none have done in such an elegant and simple fashion as Habitat, is the cluster-aware design.

Traditionally making an application cluster-aware, or able to discover services is something we add on the top of the stack, or off to the side of the deployed application. A great example of this model is [Consul][consul] or [Envoy][envoy]. Both of these projects I love, but they are an additional deployment requirement, and separated from the application itself.

Habitat's supervisor (hab-sup) joins a gossip ring on startup. It shares information about running services, making this information for applications running on the supervisor. This information is used for things like [service binding][habitat-binding], allowing at-runtime lookup of available/healthy services and binding these to the application in configuration etc.

## 3. Release / deployment management

This is a huge one, and like all the topics above, needs its own post.

Habitat builder (a repository of packages) has a concept of channels. You can consider channels to be "tags" that are applied to a package. By default, a package on builder is in the "Unstable" channel. An owner/administrator of the package can promote this to any arbitrarily named channel. One of the standards here is the "Stable" channel.

Already you can see that a single artifact produced with Habitat (which runs anywhere with a 2.6.32+ kernel) is able to be tagged in such a way that you can identify unstable and stable packages. Neat.

Further to this, the previously mentioned Habitat supervisor is capable of launching a package, subscribing to a channel for updates, and applying update strategies for that package.

For example, I have a cluster of 2 machines for development purposes for this website. They subscribe to the unstable channel of this website's package. When a new build arrives on builder, they are automatically deployed because the supervisor was instructed to subscribe to that channel. Now, this doesn't affect my prodcution deployment. The production supervisors (on a cluster of 4 machines) are instructed to subscribe to the stable channel. Deployment of a verified working site from development to production becomes a single click (promote to stable) in the habitat builder UI, or a single command line interface with the Habitat cli:

```shell
hab pkg promote grahamweldon/grahamweldon-website/0.1.0/20180807074533 stable
```

## Summary

Habitat has changed the way I work, the way I think about application deployment, and the manner in which I prepare releases. And I'm not alone in feeling this (See below tweets). Expect more posts about [Habitat][habitat] in the future!

{{< tweet 1025932244802842625 >}}

{{< tweet 1023753351962349568 >}}

[habitat]: https://www.habitat.sh
[habitat-windows]: https://www.habitat.sh/blog/2017/07/Habitat-on-Windows/
[go]: https://golang.org/
[consul]: https://www.consul.io/
[envoy]: https://www.envoyproxy.io/
[habitat-binding]: https://www.habitat.sh/docs/developing-packages/#pkg-binds
