---
title: "3 levels of monitoring"
date: 2018-09-26T00:00:00+09:00
highlight: false
draft: false
tags: ['monitoring', 'system', 'quality']
---

Monitoring is easy. Monitoring is also very difficult.

At what point do you stop adding checks to your service? And where can you start if you have none?

My process is simple, but by no means the only way to assess and monitor your systems. Everyone has their own special requirements, environments and experience. This is how I break up service checks for a networked service hosting some application. Its worked well for me, but I'd love to hear how other people approach the same problem. What is your process? How do you break it down?

There are 3 levels to monitoring/testing:

1. Environment
2. Network
3. Application

Lets look at them one by one, using a **static website** as a trivial example.

My websites are largely hosted with [Nginx][nginx], or [Caddy][caddy]. Both serve static files off the filesystem for the user on port 80 and 443. The default behaviour is to forward any *HTTP* requests to the *HTTPS* equivalent.

I then implement monitoring checks in the 3 levels.

## 1. Environment Monitoring

Environment monitoring involves checking the current system/environment for basic truths that would indicate the service / process is running as required.

* Is Nginx running?
* Is Nginx running as root?
* Is there a single master process?
* Are there multiple worker processes?

This defines the expected behaviour of Nginx, and is enough at a basic level to ensure the process behaviour is correct. Any deviation from this should alert me.

Examples:

```sh
# Is Nginx running?
ps aux | grep nginx | grep -v grep

# Is Nginx running as root?
ps aux | grep nginx | grep root | grep master

# Is there a single master process?
[ "$(ps aux | grep nginx | grep master | wc -l)" -eq 1 ]

# Are there multiple worker processes?
[ "$(ps aux | grep nginx | grep worker | wc -l)" -gt 1 ]
```

Each of these commands will return `0` if successful, and `1` if failed in some way. This is simple to plug into any monitoring system. You may need to customise further if you're running multiple Nginx processes in your server/container.

## 2. Network Monitoring

Taking a step further for networked processes, we need to ensure its listening where expected:

* Is Nginx listening on port 80?
* Is Nginx listening on port 443?
* Can I connect to port 80?
* Can I connect to port 443?

These connection checks can be a combination of local connection and remote connection, which would include monitoring any firewall rules to ensure external access is available.

Examples:

```sh
# Is Nginx listening on port 80?
netstat -peanut | grep nginx | grep 80

# Is Nginx listening on port 443?
netstat -peanut | grep nginx | grep 443

# Can I connect to port 80?
nc -z localhost 80
nc -z external.domain.name 80


# Can I connect to port 443?
nc -z localhost 443
nc -z external.domain.name 443
```

## 3. Application Monitoring

Connecting to the port in level 2 (Network monitoring) is great, but for a full check of the stack, we need to go a step further beyond simple network connection, and check that the connection represents the interface/protocol we expect.

* Is Nginx responding to HTTP requests on port 80?
* Do requests to Nginx on port 80 respond with 30x responses (redirect)?
* Is Nginx responding to HTTP requests on port 443?
* Is Nginx returning HTML to requests on port 443?

Examples:

```sh
# Is Nginx responding to HTTP requests on port 80?
curl -vvv localhost:80 2>&1 | grep "< HTTP"

# Do requests to Nginx on port 80 respond with 30x responses (redirect)?
curl -vvv --http1.1 localhost:80 2>&1 | grep "< HTTP/1\.1 30[0-9]"

# Is Nginx responding to HTTP requests on port 443?
curl -vvv https://localhost:443 2>&1 | grep "< HTTP"

# Is Nginx returning HTML to requests on port 443?
curl -vvv https://localhost:443 2>&1 | grep "<html"
```

## Conclusion

Separating these three levels of checks out allows me to grow the maturity of my monitoring for a service in stages, as required to ensure production suitability and stability.

The 3rd level (application monitoring) can be extended further to ensure that checks against a specific virtual hostname are returning the correct content. Even further, you can inspect the HTTP response to confirm validity of the document returned, or any other checks to ensure quality of your service.

For example, checking to ensure HTTP2 requests get a connection upgrade response as expected:

```sh
# Check for HTTP1.1 specifically
curl -vvv --http1.1 https://localhost:443 2>&1 | grep "< HTTP/1.1"

# Check for HTTP2 specifically
curl -vvv --http2 https://localhost:443 2>&1 | grep "< HTTP/2"
```

Its difficult to implement these all in one go, and I advocate a staged approach to monitoring. Start with level 1 as a base requirement, and add further checks as your service matures, and as you require more strict monitoring.

I haven't discussed a specific monitoring tool or technology, as I feel this approach applies to all systems.

How are you doing testing and monitoring of services? How far do you go?

[nginx]: https://www.nginx.com/ "Nginx official home page"
[caddy]: https://caddyserver.com/ "Caddy web server home page"
