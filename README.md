![Latest Release](https://gitlab.prplanit.com/precisionplanit/apt-cacher-ng-oci/-/badges/release.svg) ![Latest Release Status](https://gitlab.prplanit.com/precisionplanit/apt-cacher-ng-oci/-/raw/main/assets/badge-release-status.svg) [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T41IT163)

# apt-cacher-ng-oci — PrPlanIT Edition 🌎
This container is inspired by other work such as `sameersbn/docker-apt-cacher-ng`, retaining only a sliver of legacy scaffolding. It exists because I, **SoFMeRight (Kai)**, needed **working stdout log streaming** in a modern OCI-compatible build — and couldn't find a single working image that did it right. So I made one. 🧠

This version includes:
- Functional container log streaming via `tail -f`
- Runtime overrides for config like `PassThroughPattern`
- Secure volume handling with init-based ownership
- Graceful startup waits for logs

This is a clone of the [original repo](https://gitlab.prplanit.com/precisionplanit/apt-cacher-ng-oci), as such *this particular page may become outdated*. I do not particularly wish to automate github without being given incentive.

---

> Maintained by [PrPlanIT](https://prplanit.com) — Real world results for your real world expectations.

---

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line Arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Docker Compose](#docker-compose)
  - [Usage](#usage)
  - [Logs](#logs)
- [Maintenance](#maintenance)
  - [Cache Expiry](#cache-expiry)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)

---

## Introduction

`Dockerfile` for a containerized version of [Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/), the legendary caching proxy for Linux package archives (primarily Debian-based).

This is not just another fork — it’s a reimplementation by [Kai (@SoFMeRight)](https://github.com/sofmeright), with better operational behavior and sane logs.

## Contributing

This is maintained by a solo DevOps freak. You can:

- Send a PR or fork it and tell your friends.
- Report issues.
- [Buy me a ☕](https://ko-fi.com/T6T41IT163) if this saves you some bandwidth.

## Issues

Before opening one, make sure you're using a recent Docker version and SELinux isn’t in your way (`setenforce 0` if you want to test that). Then file here:

👉 [Open an issue](../../issues/new)

Include:

- Output of `docker version` and `docker info`
- Compose or run command used (scrub secrets)
- Environment: Docker Engine, Virtualization layer (e.g., Proxmox, Podman, etc.)

---

# Getting Started

## Installation

Pull the image from [Docker Hub (docker.io)](https://hub.docker.com/r/prplanit/apt-cacher-ng-oci/tags) or build it yourself:

```
docker pull prplanit/apt-cacher-ng-oci:latest
```
or
```
git clone https://gitlab.prplanit.com/precisionplanit/apt-cacher-ng-oci
cd apt-cacher-ng-oci
docker build -t prplanit/apt-cacher-ng-oci .
```
Hint: If the repository has already been downloaded, you can sync any upstream changes:
```
git fetch origin
git merge origin/master
```

For **extra** brownie points, you may deploy a container registry locally: 

- **Quay** is an open source, amazing option, only caveat is no caching. 
- **JFrog Container Registry** is freemium with its mildly restrictive community edition, it does docker caching similar to apt-cacher-ng but for docker right out of the box!

> A container registry is a really nice addition to a production environemnt or homelab imho, it allows you to distribute docker images to hosts on your network from a central location on prem. Setting one up would be very complimentary to apt-cacher-ng. I won't give instruction on this bit, but you have my blessing.

## Quickstart

```
docker run --name apt-cacher-ng --init -d --restart=always \
  -p 3142:3142 \
  -v /srv/apt-cacher-ng/cache:/var/cache/apt-cacher-ng \
  -v /srv/apt-cacher-ng/log:/var/log/apt-cacher-ng \
  -e APT_CACHER_NG_USER=apt-cacher-ng \
  -e APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
  -e APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
  prplanit/apt-cacher-ng-oci:latest
```

## Command-line Arguments
Custom args can be passed directly to apt-cacher-ng, for example:

```
docker run --rm -it prplanit/apt-cacher-ng-oci:latest -h
```

## Persistence
Cache and logs should persist across restarts:

```
mkdir -p /srv/apt-cacher-ng/{cache,log}
```

## Volumes:

- /var/cache/apt-cacher-ng

- /var/log/apt-cacher-ng

## Docker Compose
```
version: '3'

services:
  apt-cacher-ng:
    image: prplanit/apt-cacher-ng-oci:latest
    container_name: apt-cacher-ng-oci
    ports:
      - "3142:3142"
    volumes:
      - ./cache:/var/cache/apt-cacher-ng
      - ./log:/var/log/apt-cacher-ng
    restart: unless-stopped
    environment:
      APT_CACHER_NG_USER: apt-cacher-ng
      APT_CACHER_NG_CACHE_DIR: /var/cache/apt-cacher-ng
      APT_CACHER_NG_LOG_DIR: /var/log/apt-cacher-ng
```

Start with:

```
docker-compose up -d
```

## Usage
To enable on your Debian-based systems, create or update:

```/etc/apt/apt.conf.d/01proxy```

```
Acquire::HTTP::Proxy "http://<your-host-ip>:3142";
Acquire::HTTPS::Proxy "false";
```

Dockerfile snippet:

```
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
 ```

## Logs
This image streams logs to stdout! 🎉
You can also peek inside the logs directly:

```
docker logs -f apt-cacher-ng
```

Or:

```
docker exec -it apt-cacher-ng tail -f /var/log/apt-cacher-ng/apt-cacher.log
```

## Maintenance
### Cache Expiry
Run with the -e flag:

```
docker run --rm -it \
  -v /srv/apt-cacher-ng/cache:/var/cache/apt-cacher-ng \
  prplanit/apt-cacher-ng-oci:latest -e
```

Or via web UI:

http://localhost:3142/acng-report.html → Start Scan and/or Expiration

### Upgrading

```
docker pull prplanit/apt-cacher-ng-oci:latest
docker stop apt-cacher-ng && docker rm apt-cacher-ng
```
\# then restart using your run or compose setup
### Shell Access

```
docker exec -it apt-cacher-ng bash
```

---

This container is maintained by SoFMeRight for PrPlanIT — Real world results for your real world expectations.

---

## Disclaimer

> The Software provided hereunder (“Software”) is licensed “as-is,” without warranties of any kind—express, implied, or telepathically transmitted. The Softwarer (yes, that’s totally a word now) makes no promises about functionality, performance, compatibility, security, or availability—and absolutely no warranty of any sort. The developer shall not be held responsible, even if the software is clearly the reason your dog ran off to join a circus, or your mom scored five tickets to Hawaii but you missed out because you were knee-deep in a gaming bender.

> If using this caching proxy leads you down a rabbit hole of obsessive network optimizations, breaks your fragile grasp of version pinning, or causes an uprising among your offline-first containers—sorry, still not liable. Also not liable if your repo mirror syncs so fast it rips a hole in the space-time continuum. The developer likewise claims no credit for anything that actually goes right either. Any positive experiences are owed entirely to the brilliant folks behind the original tools, their forks, and the unstoppable force that is the Open Source community.

> It’s never been a better time to be a PC user—just don’t blame me when it inevitably eats your weekend.
