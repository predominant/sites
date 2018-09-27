---
title: "Habitat configuration/wrapper plans"
date: 2018-09-27T00:00:00+09:00
highlight: false
draft: false
tags: ['habitat', 'configuration', 'development']
---

This post has been a long time coming. For about 2 years, configuration plans (Also known as wrapper plans) have been a critical part of how I use and deploy [Habitat][habitat] plans/artifacts in the wild. They're a super easy way to encapsulate some required software and bundle your own configuration. For some reason, finding information about this approach has previously been difficult due to a lack of documentation.

Here's an example of configuration plans for Habitat.

## Introduction

We'll keep this example trivial, but easy to repurpose for other plans.

Terminology:

* A habitat **package** is a built artifact that can be installed.
* A habitat **plan** is the source (shell code) that is used to build the package.
* This post describes a **configuration plan** which is a common/useful pattern for writing plans.

I'll assume you've already [installed Habitat][install-habitat] for the rest of this post.

Scenario: We have a super important message to post on the internet, in a static html file. And we want to host this with [Nginx][nginx]. Fortunately the Habitat community has an [Nginx package][nginx-package] ([source code for the plan here][nginx-plan]) that we can use!

## Create the plan

Create a new plan:

```sh
hab plan init mywebsite
```

Once that completes, change into the plan directory:

```sh
cd mywebsite
```

## Create your content

Lets start by creating our content. Create a new file `index.html` in a directory called `public`:

```sh
mkdir -p public
echo "<h1>Hello world</h1>" > public/index.html
```

With our webpage ready, its time to build the configuration wrapper for Nginx.

## Modify the plan.sh

Edit the `plan.sh` file that Habitat generated for us:

```sh
pkg_name=mywebsite
pkg_origin=grahamweldon
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_deps=(core/nginx)
pkg_svc_run="nginx -c ${pkg_svc_config_path}/nginx.conf"
pkg_exports=(
  [port]=port
)
pkg_exposes=(port)
pkg_svc_user="root"
pkg_svc_group="root"

do_build() {
  return 0
}

do_install() {
  cp -r public "${pkg_prefix}"
}
```

{{% tip %}}
You should set `pkg_origin` here to your own origin name.
{{% /tip %}}

This plan overrides the `do_build` step to do nothing, and overrides the `do_install` step to copy the `index.html` file into place in the resulting package path.

## Custom Configuration

Next, create your custom Nginx `nginx.conf` file in `config/nginx.conf`

```text
worker_processes 4;
pid {{pkg.svc_var_path}}/pid;
daemon off;
events {
  worker_connections 1024;
}
http {
  client_body_temp_path {{pkg.svc_var_path}}/client-body;
  fastcgi_temp_path     {{pkg.svc_var_path}}/fastcgi;
  proxy_temp_path       {{pkg.svc_var_path}}/proxy;
  scgi_temp_path        {{pkg.svc_var_path}}/scgi_temp_path;
  uwsgi_temp_path       {{pkg.svc_var_path}}/uwsgi;
  default_type          text/html;
  server {
    listen       {{cfg.port}};
    server_name  localhost;
    location / {
      root   {{pkg.path}}/public;
      index  index.html;
    }
  }
}
```

In this example, I've actually simplified the configuration by hardcoding some values, and removing some logic from the configuration. However you could go the other way, making the configuration include more logic/switching and tests to include more options and cover more scenarios. At this point, the configuration is yours to own and manage.

## Testing

Thats it. Time to build and test!

Enter the Habitat studio, and build:

```sh
hab studio enter

build
```

{{% tip %}}
Remember to replace "grahamweldon" in the example with your own origin name.
{{% /tip %}}

## Observations

Notice how quick that was to build? It should have taken no time at all! While writing this post, builds for me were taking 13 seconds. This includes the download time for all dependencies (Nginx, etc.)

Now you can load the service, and check it out:

```sh
hab svc load grahamweldon/mywebsite

hab pkg install --binlink core/curl
curl -vvv http://localhost
```

You will see the following:

```text
# curl http://localhost
<h1>Hello world</h1>
```

Congratulations! You've just wrapped Nginx in a Habitat configuration plan!

## Conclusion

Generally I feel that you should never be deploying a **core plan** to your servers. Core plans are maintained by the community and they are a great resource that you can depend on. However they are [subject to change][mongodb-pr], and can impact your service operation.

The best scenario is to take the core plans as a dependency for binaries that you rely on for your deployment. Use the core plans configuration as a reference, but use a **configuration plan** implementation to construct and deploy your own configuration.

Much like a Linux distribution's package manager, Habitat will ship default configs that work for trivial/common setups. Anything beyond that simple usecase is the responsibility of the user (you) and belongs in a configuration plan.

[habitat]: https://www.habitat.sh/
[nginx]: https://www.nginx.com/
[nginx-package]: https://bldr.habitat.sh/#/pkgs/core/nginx
[nginx-plan]: https://github.com/habitat-sh/core-plans/blob/master/nginx/plan.sh
[mongodb-pr]: https://github.com/habitat-sh/core-plans/pull/1771
[install-habitat]: https://www.habitat.sh/docs/install-habitat/
