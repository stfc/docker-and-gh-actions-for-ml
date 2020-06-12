---
title: 3. Containerise it
---

# 3. :package: Containerise it

Our next step is going to be to take our API and containerise it - in other words, we're going to build a Docker image to bundle up our server so that we can run it anywhere!

## What are containers?

Before we start coding away, let's first explain what containers are and how they work.

!!! note
    If you're already familiar with this, feel free to skip ahead to the [next bit](#making-the-dockerfile).

### Terminology

First of all, let's get a bit of terminology out of the way:

**Container image** - a built self-contained bundle holding all the files, code & dependencies to run whatever it is you're working on.

**Container** - a running instance of a container image. You can run as many container instances as you want from a single image, and once the container is running you can access a shell in that container and run whatever commands you want like any other command line[^1]. This can be super useful for debugging any problems!

[^1]: This assumes that the image you're working with has a shell installed - if you have an image using the [scratch](https://hub.docker.com/_/scratch) image, you won't have *anything* like this. It's precisely for this reason that using this image isn't recommended unless you specifically need *very very* small Docker images.

**Container engine** - The software that handles all the container-related tasks like building images, running containers, killing containers, etc.

**Container registry** - This is a server that acts as a library for storing and retrieving images. There are public ones like [Docker Hub](https://hub.docker.com/) and [Singularity Hub](https://singularityhub.com/), but we're gonna be spinning up and using our own private registry, because we don't want to have our API images open to the public!

**Tag** - This is a label that you apply to an image. This is usually a version but it can be anything you want! There's one special tag, though: `latest`. This should point to the latest, greatest version of your image. If you're looking for most up-to-date version of any other application's image, you can always look for that `latest` tag.

**Base image** - Container images work in layers so that images can be re-used as the basis for another image. This is called the "base" of your image. What this is really telling Docker (or other engine) is that your image is really just this base image, with a few bits added. Your output image will contain all the layers for your base image, but with an extra layer (or more) for the changes you've added on top. This layer re-use makes downloading derivative images much quicker and more efficient.

### How does it work?

Containers are fundamentally a Linux technology! [^2]

[^2]: In fact, if you're running Docker on either macOS or Windows, you'll be running a Linux virtual machine under the hood - all of the container cleverness happens inside the virtual machine's Linux kernel.

In fact, containers are really a collection of features of the Linux kernel that enable you to namespace things like filesystems, processes, networks and memory. What this means is that a container can have it's own processes that run *completely isolated* from the rest of your system, and this separation is enforced at the kernel level.

There's no way that another container or process outside of the container runtime can access anything inside your image because the kernel enforces the isolation. This is a really simple concept (the specifics of the implementation are not so simple) but the power and versability that you can get out of this simple idea are pretty extraordinary!

As all the running containers on your machine share the same kernel, there's much less runtime overhead for containers vs. virtual machines and the container images themselves can be a just few kilobytes instead of gigabytes.

![Virtual machines vs. containers. From: https://blog.netapp.com/blogs/containers-vs-vms/](/images/containerise-it/vm-vs-container.png)

From: https://blog.netapp.com/blogs/containers-vs-vms/
{: style="font-size: small; margin-top: -30px; width: 100%; text-align: center;"}

If you want to get a deeper understanding of how containers work under the hood, I'd highly recommend the [blog posts](https://jvns.ca/categories/containers/) and [zines](https://wizardzines.com/zines/containers/) by [Julia Evans](https://twitter.com/b0rk).

### Container technologies

As far as container runtimes go, there's a whale of a market dominator, and a few others used for more specific purposes (some of which are slowly gaining ground).

#### Docker

![Docker logo](/images/containerise-it/docker.png){: style="height: 100px; float: right;"}

This is the main player in the container world, by far. The metaphorical whale. (It's also the one with the whale logo.) Docker was the company that popularised containerisation, which means the formats created by Docker had a massive impact on the container landscape.

While Docker Inc. is a private company, all of the code behind it is [Open Source](https://github.com/docker/). They also spun out their [core container runtime](https://containerd.io/) functionality into a separate component and donated it to the care of the [Cloud Native Computing Foundation](https://www.cncf.io/), a part of the non-profit [Linux Foundation](https://www.linuxfoundation.org/).

In June 2015, Docker and other container companies established the [Open Container Initiative](https://www.opencontainers.org/) - this organisation is also a Linux Foundation project and designs the specifications for the container runtime - [runtime-spec](https://github.com/opencontainers/runtime-spec) and image format - [image-spec](https://github.com/opencontainers/image-spec).

#### Podman

![Podman logo](/images/containerise-it/podman.svg){: style="height: 100px; float: right;"}

Even though it dominates the market, Docker isn't the only container runtime around with a logo of a happy cute sea animal!

Enter [Podman](https://podman.io/).

The main differentiator between Docker and Podman is that Podman doesn't need a daemon running as root in the background[^3]

[^3]:
    In fact, the Docker daemon *can* run in [rootless mode](https://docs.docker.com/engine/security/rootless/), but this is very early stage and still has some big limitations.

#### Singularity

![Singularity logo](/images/containerise-it/singularity.svg){: style="height: 100px; float: right;"}

Singularity is similar to Podman in arising out of a need for a rootless container runtime. Singularity also maintains full support for Docker images (they really are the de-facto standard).

The main difference is that Singularity is aimed at the scientific computing market - it's designed to work with HPC systems and allow for easily running containerised HPC workloads without any significant overhead and without needing any special privileges.

#### Rkt

![Rkt logo](/images/containerise-it/rkt.svg){: style="height: 100px; float: right;"}

[Rkt](https://coreos.com/rkt/) is developed by CoreOS to be compatible with Docker images but with more of a focus on better security through customisable isolation. It's mainly advertised as a container runtime replacement for large production-ready Kubernetes clusters. Recently, Red Hat acquired CoreOS and as a result development of Rkt stopped and the [GitHub Repository](https://github.com/rkt/rkt) was archived.

## Making the Dockerfile

Our entrypoint into the world of containers is the `Dockerfile`. This file contains a series of steps that Docker[^4] will run in order to produce your image.

[^4]: I'm going to refer to Docker for the rest of this tutorial for brevity's sake - just remember that it will also apply to other container engines.

Let's get started!

Our API is written in Go, and there's already a Docker image for building Go code! Let's try it out...

!!! example "`Dockerfile`"
    ```dockerfile linenums="1"
    # We use the standard Golang image as our "base image" (see terminology above
    # for what that means).
    FROM golang:latest

    # Copy all of the code in repository into this image so that we can build it.
    COPY . .

    # This runs the make command when *building* the image. Note that we want to make
    # sure we're compiling the executable for Linux to be able to run inside the
    # container.
    RUN make build-linux

    # Now that we've got our Docker image, we can specify what command to run
    # when running our image.
    CMD ["./hbaas-server"]
    ```

These Dockerfiles are pretty simple - each line is a command to Docker that are run in the order that they're written. You can find a full list of all the Dockerfile commands, along with the full explanations, at: https://docs.docker.com/engine/reference/builder/

What this Dockerfile will do is take the Go Docker image from [Docker Hub](https://hub.docker.com/), copy all of our code into the image from the directory we're in, build the app and specify the image entry point (i.e. the command that it'll run when you run the container).

We're also going to add a [`.dockerignore` file](https://docs.docker.com/engine/reference/builder/#dockerignore-file) - this is exactly like a `.gitignore` but tells Docker that, even if we say `COPY . .`, we don't need to worry about certain files. Let's create one and put a few standards things in (this'll speed up the image build time and often reduces the output image size too[^5]):

[^5]: In this particular case, we'll be using a builder image separate from the output image at the end, so it won't have an image on the final image size. In general though, the more you can ignore with the `.dockerignore`, the better!

!!! example "`.dockerignore`"
    ```bash linenums="1"
    # Application-specific cache directories
    .go-bin
    .go-pkg

    # General things to ignore
    .git
    .env

    # macOS files
    .DS_Store

    # IDE files
    .idea
    .vscode
    *.swp
    *.swo
    .*.swp
    .*.swo
    *~
    .*~
    ```

Now, let's give it a build (replace `my-org` with the name of your organisation):

```bash
# The `-t` specifies the 'tag', which is used when we upload the image to our
# repository a bit later.
$ docker build -t my-org/hbaas:latest .
```

!!! info
    This will have to download the large (~1.5 GB last time I checked) `golang:latest` image from Docker Hub if you haven't used it before.

    If you have, Docker will use the cached layers. Docker layer caching is actually pretty neat! We'll talk about it a bit more in a sec.

If all goes well, this should see a bunch of output that looks like this:

```bash
...
go: finding github.com/pelletier/go-toml v1.6.0
go: finding github.com/spf13/afero v1.2.2
go: finding github.com/spf13/cast v1.3.0
go: finding github.com/spf13/jwalterweatherman v1.1.0
go: finding github.com/subosito/gotenv v1.2.0
go: finding gopkg.in/yaml.v2 v2.2.7
Removing intermediate container 1cfff360a27c
 ---> bd44400184d2
Step 4/4 : CMD ["./hbaas-server"]
 ---> Running in dd5fd18006bd
Removing intermediate container dd5fd18006bd
 ---> 982177ee08f5
Successfully built 982177ee08f5
Successfully tagged my-org/hbaas:latest
```

Great! We've built and tagged our HBaaS Docker image!

If you wanted to, you could take this image and run your service using it - it works! We're not going to do that though, because we're going to be a bit more clever about it.

## Consider the cache!

Notice how after each command, there's a hexadecimal identifier shown like this:

```bash
 ---> 982177ee08f5
```

This is because after every single command that Docker runs, it does a bunch of clever stuff where it saves the image at that point in time in its cache and gives it an identifier.

If you change the Dockerfile or your code, Docker will be able to look through the previous images you've built and see whether it can re-use any of the "saved steps"
and skip out actually running the commands.

If you leverage this in your Dockerfile, you can change Docker build times after a code change from minutes (and sometimes hours for very large images with lots of build steps!) into just a few seconds.

This might not seem too important for a small image like this, and it's not, but as your Docker images get more complex and your Dockerfiles get longer, the cache will be more and more important!

So let's look at making this more cache efficient.

!!! example "`Dockerfile`"
    ```Dockerfile hl_lines="5-8" linenums="1"
    # We use the standard Golang image as our "base image" (see terminology above
    # for what that means).
    FROM golang:latest

    COPY Makefile .
    COPY go.mod .
    COPY go.sum .
    RUN make download-dependencies

    # Copy all of the code in repository into this image so that we can build it.
    COPY . .

    # This runs the make command when *building* the image.
    RUN make build-linux

    # Now that we've got our Docker image, we can specify what command to run
    # when running our image.
    CMD ["./hbaas-server"]
    ```

What this means is that we can download all of our dependencies before we do the important `COPY . .` command. This way, is we change any of our source files and re-run the `docker build` command, our Docker build will skip straight through the steps to the `COPY . .`.

!!! tip
    You can try this out by modifying one of the source files, like `main.go`, add an extra log in or whatever, and re-running the `docker build` command.

## Using a multi-stage Dockerfile

If we take a look at the image that we've generated using this Dockerfile, we can see that it's _pretty big_:

```bash
$ docker images
> REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
> my-org/hbaas        latest              7a564cc27629        2 minutes ago       1.11GB
```

Considering all we need at the end is our 14 MB `hbaas-server` executable, 1.11 GB seems pretty hefty! Don't fret though, we can take advantage of Docker's multi-stage builds to trim that output image size right down.

We'll need to make some changes to our `Dockerfile`:

!!! example "`Dockerfile`"
    ```Dockerfile linenums="1" hl_lines="1-8 21-34"
    # Builder stage
    # =============

    # We use the standard Golang image as our "base image" (see terminology above
    # for what that means).
    FROM golang:latest AS builder
    
    WORKDIR /app

    COPY Makefile .
    COPY go.mod .
    COPY go.sum .
    RUN make download-dependencies

    # Copy all of the code in repository into this image so that we can build it.
    COPY . .

    # This runs the make command when *building* the image.
    RUN make build-linux

    # Runner stage
    # ============

    FROM alpine

    COPY --from=builder /app/hbaas-server /app/

    # Required for some cloud providers for remote access.
    RUN apk add bash

    # Document that our service listens on port 8000
    EXPOSE 8000

    CMD ["/app/hbaas-server"]
    ```

Now if we check our image sizes now with our fancy new multi-stage build, we can see a _significant_ improvement:

```bash
$ docker build -t hbaas-server .
$ docker images
> REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
> hbaas-server        latest              7518b4973c75        33 seconds ago      24.5MB
```

!!! note
    We're using the [Alpine](https://alpinelinux.org/) image here which is basically a super-lightweight Linux distro which is really popular for making Docker images because of it's tiny size. We can see here that it's adding around 10 MB on top of our executable. Not bad!

    In fact, technically we don't even need Alpine! We could equally have done `FROM scratch` instead which would contain literally no other files! The only reason we're not doing this is that cloud providers (such as IBM Cloud) often require basic utilities like Bash installed to work properly.

## Tagging the image with the version

If you remember back to [Section 1](/1-setting-up-git-flow/), we used `git describe` to automatically get the version in semver format from our git flow.

We can use this same tactic to automatically tag our Docker images with their version!

!!! example "`Makefile`"
    ```Makefile linenums="65" hl_lines="4-14"
        GOPATH=$(GOPATH) GOBIN=$(GOBIN) go mod download
        test -e $(GOBIN)/go-bindata || GOPATH=$(GOPATH) GOBIN=$(GOBIN) go get github.com/kevinburke/go-bindata/...

    ## build-image: Build Docker container image for API.
    build-image:
        $(call log,Building Docker image...)
        docker build \
            --build-arg version=$(VERSION) \
            --tag $(PROJECTNAME):latest . \
            --tag $(PROJECTNAME):$(VERSION) . || \
        (\
            $(call log-error,Unable to build Docker image.) \
            && false \
        )

    .PHONY: clean
    ## clean: Clean up all build files.
    ```

Notice that we're passing in the version and build time through to the Docker image via the `--build-arg` command-line option. This is because the `git describe` won't work when we do the `make build` because the `.git` folder is being excluded from the Docker image via the Dockerfile.

Now you should be able to see why we used the `?=` for `VERSION` instead of `:=` - we can now specify the version as an argument to the `docker build` command and pass that value through to the `Makefile` - pretty clever!

This does require a small change to the Dockerfile so that we can pass the version through to the build:

!!! example "`Dockerfile`"
    ```Dockerfile hl_lines="3-4" linenums="6"
    FROM golang:latest AS builder

    ARG version
    ENV VERSION=$version

    WORKDIR /app
    ```

## Let's create our private repository

Next we're going to upload our images to a private repository in IBM Cloud - this will allow us to run our API from the image hosted in our private repository.

This assumes that you've logged into the CLI as per the instructions in [Section 0](/0-installing-dependencies/) - make sure you've done this before proceeding. (If logged in a while ago, you may need to do it again to refresh the access token.)

Firstly, we need to set up the IBM Cloud CLI to work with our container registry:

```bash
# The container registry CLI functionality is kept in a separate plugin which needs to be installed.
$ ibmcloud plugin install container-registry -r 'IBM Cloud'

# Set our region to UK South (i.e. London) - if you're using a different region you'll
# need to update this accordingly.
$ ibmcloud cr region-set uk-south

# If this fails, you may need to re-run `ibmcloud login --sso`.
$ ibmcloud cr login

# Create a namespace to put our images in - make sure to replace this with something
# meaningful to your organisation.
$ ibmcloud cr namespace-add my-org

# Check that our namespace is there.
$ ibmcloud cr namespaces
> Listing namespaces for account '(your account)' in registry 'uk.icr.io'...
>
> Namespace
> my-org
```

!!! tip
    If you aren't able to run these commands on the container registry, your IBM Cloud account might not have the necessary permissions to interact with the Kubernetes part of IBM Cloud, which is required to use the container registry.

    If that's the case, get in contact ASAP so that we can give you the permissions you need!

If you can see your namespace in the output of that final command then congratulations, you've created your container registry namespace!

## Time to upload our image

Now we're going to upload our image into the registry. We're going to use the `Makefile` so that we can re-use our automatic version detection.

This means adding a new target like so:

!!! example "`Makefile`"
    At the beginning of the file:
    ```Makefile linenums="3" hl_lines="4"
    SHELL := /bin/bash

    PROJECTNAME := hbaas-server
    DOCKERREGISTRY := uk.icr.io/my-org

    # Go related variables.
    GOBASE := $(shell pwd)
    ```

    Towards the end of the file:

    ```Makefile linenums="70" hl_lines="6-7 13-26"
    ## build-image: Build Docker container image for API.
    build-image:
    	$(call log,Building Docker image...)
    	docker build \
    		--build-arg version=$(VERSION) \
    		--tag $(DOCKERREGISTRY)/$(PROJECTNAME):$(VERSION) \
    		--tag $(DOCKERREGISTRY)/$(PROJECTNAME):latest . || \
    	(\
    	    $(call log-error,Unable to build Docker image.) \
    	    && false \
    	)

    ## upload-image: Build Docker image and upload to private registry.
    upload-image: build-image
    	$(call log,Uploading Docker image...)
    	ibmcloud cr login
    	docker push $(DOCKERREGISTRY)/$(PROJECTNAME):$(VERSION) || \
    	(\
    	    $(call log-error,Unable to deploy Docker image to repository.) \
    	    && false \
    	)
    	docker push $(DOCKERREGISTRY)/$(PROJECTNAME):latest || \
    	(\
    	    $(call log-error,Unable to deploy Docker image to repository.) \
    	    && false \
    	)

    .PHONY: clean
    ## clean: Clean up all build files.
    clean:
    ```

If you now run `make upload-image`, you should see something like this:

![upload image output](/images/containerise-it/upload-image-output.png)

!!! success
    Great work! Now you've containerised your application and uploaded the image to your private container registry.

    Now you're ready to start automating all these tasks using continuous integration.
