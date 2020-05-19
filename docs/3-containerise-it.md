---
title: 3. Containerise it
---

# 3. :package: Containerise it

Our next step is going to be to take our API and containerise it - in other words, we're going to build a Docker image holding all code and dependencies required to run our server.

## What are containers?

Before we start coding away, let's first explain what containers are and how they work.

If you're already familiar with this, feel free to skip ahead to the [next section](#making-the-dockerfile).

### Terminology

First of all, let's get a bit of terminology out of the way:

**Container image** - a built self-contained bundle holding all the files, code & dependencies to run whatever it is you're working on.

**Container** - a running instance of a container image. You can run as many container instances as you want from a single image, and once the container is running you can access a shell in that container and run whatever commands you want like any other command line[^1]. This can be super useful for debugging any problems!

[^1]: This assumes that the image you're working with has a shell installed - if you have an image using the [scratch](https://hub.docker.com/_/scratch) image, you won't have *anything* like this. It's precisely for this reason that using this image isn't recommended unless you specifically need *very very* small Docker images.

**Container engine** - The software that handles all the container-related tasks like building images, running containers, killing containers, etc.

**Container registry** - This is server that acts as a library for storing and retrieving images. There are public ones like [Docker Hub](https://hub.docker.com/) and [Singularity Hub](https://singularityhub.com/), but we're gonna be spinning up and using our own private registry, because we don't want to have our API images open to the public!

### How does it work?

Containers are fundamentally a Linux technology! [^2]

[^2]: In fact, if you're running Docker on either macOS or Windows, you'll be running a Linux virtual machine under the hood - all of the container cleverness happens inside the virtual machine's Linux kernel.

In fact, containers are really a collection of features of the Linux kernel that enable you to namespace things like filesystems, processes, networks and memory. What this means is that a container can have it's own processes that run *completely isolated* from the rest of your system, and this separation is enforced at the kernel level.

There's no way that another container or process outside of the container runtime can access anything inside your image because the kernel enforces the isolation. This is a really simple concept (the specifics of the implementation are not so simple) but the power and versability that you can get out of this simple idea are pretty extraordinary!

As all the running containers on your machine share the same kernel, there's much less runtime overhead for containers vs. virtual machines and the container images themselves can be a just few kilobytes instead of gigabytes.

![Virtual machines vs. containers. From: https://blog.netapp.com/blogs/containers-vs-vms/](images/vm-vs-container.png)

From: https://blog.netapp.com/blogs/containers-vs-vms/
{: style="font-size: small; margin-top: -30px; width: 100%; text-align: center;"}

If you want to get a deeper understanding of how containers work under the hood, I'd highly recommend the [blog posts](https://jvns.ca/categories/containers/) and [zines](https://wizardzines.com/zines/containers/) by [Julia Evans](https://twitter.com/b0rk)

### Container technologies

As far as container runtimes go, there's a whale of a market dominator, and a few others used for more specific purposes (some of which are slowly gaining ground).

#### Docker

![Docker logo](images/docker.png){: style="height: 100px; float: right;"}

This is the main player in the container world, by far. The metaphorical whale. (It's also the one with the whale logo.) Docker was the tech that popularised containerisation, which means that now the Docker runtime, Docker image format and Dockerfile format are the de-facto standards for containerisation.

While Docker Inc. is a private company, all of the code behind it is [Open Source](https://github.com/docker/). They also spun out their [core container runtime](https://containerd.io/) functionality into a separate component and donated it to the care of the [Cloud Native Computing Foundation](https://www.cncf.io/), a part of the non-profit [Linux Foundation](https://www.linuxfoundation.org/).

#### Podman

![Podman logo](images/podman.svg){: style="height: 100px; float: right;"}

Even though it dominates the market, Docker isn't the only container runtime around with a logo of a happy cute sea animal!

Enter [Podman](https://podman.io/).

The main differentiator between Docker and Podman is that Podman doesn't need a daemon running as root in the background[^3]

[^3]:
    In fact, the Docker daemon *can* run in [rootless mode](https://docs.docker.com/engine/security/rootless/), but this is very early stage and still has some big limitations.

#### Singularity

![Singularity logo](images/singularity.svg){: style="height: 100px; float: right;"}

Singularity is similar to Podman in arising out of a need for a rootless container runtime. Singularity also maintains full support for Docker images (they really are the de-facto standard).

The main difference is that Singularity is aimed at the scientific computing market - it's designed to work with HPC systems and allow for easily running containerised HPC workloads without any significant overhead and without needing any special privileges.

#### Rkt

![Rkt logo](images/rkt.svg){: style="height: 100px; float: right;"}

[Rkt](https://coreos.com/rkt/) is developed by CoreOS to be compatible with Docker images but with more of a focus on better security through customisable isolation. It's mainly advertised as a container runtime replacement for large production-ready Kubernetes clusters. Recently, Red Hat acquired CoreOS and as a result development of Rkt stopped and the [GitHub Repository](https://github.com/rkt/rkt) was archived.

## Making the Dockerfile

Our entrypoint into the world of containers is the `Dockerfile`. This file contains a series of steps that Docker[^4] will run in order to produce your image. Let's get started.

Our API is written in Go, and there's already a Docker image for building Go code! Let's try it out...

```dockerfile
FROM golang:latest

COPY . .

RUN make compile

CMD ["./hbaas"]
```

[^4]: I'm going to refer to Docker for the rest of this tutorial for brevity's sake - just remember that it will also apply to other container engines.
