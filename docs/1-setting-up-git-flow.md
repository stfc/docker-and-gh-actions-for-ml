---
title: 1. Setting up git flow
---

# 1. :twisted_rightwards_arrows: Setting up git flow

## Git flow

The branching model we're going to be using is the following:

![git flow branching model](images/git-flow.png)

This is a very common and very popular branching model (although many people adapt or extend it).

The main important info about this branching model to bear in mind when thinking about how the git repository represents the service you're building is:

- The `master` branch always represents the _production-ready_, released version of the code.
- All merges into the `master` branch should be tagged with the version number, according to the [Semantic Versioning (SemVer)](https://semver.org/) standard.
- The `dev` (or `development`) branch represents the current tip of the development effort for your code. It should contain the latest updates in a working state (but if your dev branch is broken for a while, it's not a big deal).
- No work should be done directly on the `dev` or `master` branches - instead, they should be branches out, completed and then merging back in (preferably after a pull request and peer review).
- Features and non-urgent bug fixes should be branched from the `dev` branch.
- Urgent bug fixes (a.k.a. hotfixes) that need to be immediately updated on the production code should be branched from the `master` branch, and merged into both the `master` and `dev` branches when ready.

## Quick explanation of SemVer

Some of you might not have encountered Semantic Versioning or SemVer before - the basic idea is super simple (although you wouldn't think so looking at the full specification).

Each version has 3 numbers, separated by full-stops, and an optional label at the end, like this:

![SemVer Demo](images/semver.png)

From: https://forums.ubports.com/topic/1822/semantic-versioning-for-ut
{: style="font-size: small; margin-top: -30px; width: 100%; text-align: center;"}

The important thing about SemVer is that any backwards-incompatible (a.k.a. breaking) changes requires you to increment the "major" number.

Let's take an example - I'm working on my app and I'm on version 3.6.1.

If I make a small change somewhere - maybe fixing some minor bug or changing the wording somewhere, I would bump my version up to 3.6.2.

If I make a bigger change, like adding a new endpoint to my service, I would bump my version up to 3.7.0.

If I change the input for an existing endpoint so that people have to change their code to interact with my service, that would be a backwards-incompatible breaking change and so would require me to bump my version to 4.0.0. For this reason, it is common to lump together breaking changes so that you're reducing the number of different major updates as much as possible.

!!! note
    It's commonly understood that if you're in version 0.x.x, you're in the rapid prototyping phase and so can have breaking changes without needing to bump up major version number.

    When you release version 1.0.0, you're essentially announcing to the world that you will adhere to the SemVer guidelines going forwards.

## Cloning the repo

Now that we've got the theory out the way, let's get started!

First things first, let's clone the repository containing the code that we'll be working with for this tutorial, and get it set up on our system.

```sh
git clone git@gitlab.com:drewsilcock/go-with-the-flow-code.git
```

!!! info
    If you haven't set up an SSH key to use with git, I'd highly recommend doing so by following the instructions here: https://docs.gitlab.com/ee/ssh/.

    If you have issues with this, you can always clone from the HTTPS URL instead of the SSH endpoint:

    ```sh
    git clone https://gitlab.com/drewsilcock/go-with-the-flow-code.git
    ```

If you look at the current structure of the repo, there are a bunch of branches called `tutorial/section-X` where `X` corresponds to one of these sections - you'll start of on branch `tutorial/section-1`, because that's where the tutorial starts! :slightly_smiling_face:

If you get stuck or want to skip forwards a section, you can just checkout another one of these branches to get the code needed to get going.

!!! note
    You'll still need to follow this section to get the branches set up for the git flow branching model so that we can use it later for the continuous deployment.


## Forking the repo in GitLab

We're going to be working with GitLab CI/CD, which means we need to fork the repository into our own space.

If you don't already have a GitLab account set up on gitlab.com, go ahead and head over to https://gitlab.com/users/sign_up and create your account.

Next, head over to https://gitlab.com/drewsilcock/go-with-the-flow-code and click on the "Fork" button.

Once we've forked the repo into our own account space, we want to set our git remotes so that we can push up to your new forked repo:

```sh
git remote set-url origin git@gitlab.com:{my-username}/go-with-the-flow-code.git

# You can double check that your origin is pointing to the right location like so:
git remote -v
```

where `{my-username}` is your GitLab username.

## Setting up our branches

We only have the `tutorial/section-X` branches right now - not even a master branch! That's the first thing we'll need to create.

```sh
git checkout -b master
git push --set-upstream origin master
```

Great. Now that we've got a master branch, let's tag out very first release:

```sh
git checkout master
git tag -a v1.0.0
git push --tags
```

!!! info "Code signing tags"
    In generic, I would very much recommend creating a GPG key and signing your commits and tags using that key. You can then upload your public GPG key to GitLab to show whether your commits and tags are verified.

    Having an expectation of signing your git activity is a really good position to be in from a security perspective.

    If you do want to sign your tags, you simply run:

    ```sh
    git tag -s v1.0.0
    ```

    While code signing is thoroughly recommended, setting up the relevant keys is outside the scope of this tutorial.

    For more information, GitHub has [plenty of info on GPG and git](https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key).

Next, let's create our `dev` branch.

```sh
git checkout -b dev
git push --set-upstream origin dev
```

## Setting the API version

We want to be able to specify the version inside our application so that we can check what version the API is running dynamically.

Well there's good news - we can get git to do this for us automatically!

Ie you've set up your git flow and you're on either your master or dev branches, we can get our current version in semver format by simply running:

```bash
$ git describe --tags --always
```

!!! info
    To make sure that `git describe` always gives you the correct information on both master and dev branches, there's a slight modification required to the git flow. That is, once you've merged dev into the master branch and tagged the release, you should merge back into the develop branch.

    What this does is ensure that the tagged commit (i.e. the merge into master) is present on both master and dev, which ensures that git can accurately get the version from both branches.

!!! tip
    Git will automatically add an extra bit to the version number based on how many commits ahead you are, which takes the place of the optional pre-release label.

    For instance, if you were on version 0.6.3 but then made 2 commits on top, you would get out something like:

    ```bash
    $ git describe --tags --always
    > v0.6.3-2-g1a64609
    ```

    Here the `2` indicates that we are 2 commits ahead of tag `v0.6.3` and the `g1a64609` is the shortened hash of the commit that we're on.

If we make a small adjustment to our `Makefile`, we can include the version in the application using [special flags for the linker](https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications) (you only need to add the highlighted lines, don't worry too much about the rest):

!!! example "`Makefile`"
    ```Makefile linenums="1" hl_lines="15-19 45"
    -include .env

    SHELL := /bin/bash

    PROJECTNAME := hbaas-server

    # Go related variables.
    GOBASE := $(shell pwd)
    GOPATH := $(GOBASE)/.go-pkg:$(GOBASE)
    GOBIN := $(GOBASE)/.go-bin
    GOFILES := $(wildcard *.go)

    PACKAGENAME := $(shell go list)

    VERSION ?= $(shell git describe --tags --always)
    BUILDTIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

    LDFLAGS := -ldflags "-X '$(PACKAGENAME)/version.Version=$(VERSION)' \
                         -X '$(PACKAGENAME)/version.BuildTime=$(BUILDTIME)'"

    # Make is verbose in Linux. Make it silent.
    MAKEFLAGS += --silent

    IS_INTERACTIVE := $(shell [ -t 0 ] && echo 1)

    ifdef IS_INTERACTIVE
    LOG_INFO := $(shell tput setaf 12)
    LOG_ERROR := $(shell tput setaf 9)
    LOG_END := $(shell tput sgr0)
    endif

    define log
    echo -e "$(LOG_INFO)⇛ $(1)$(LOG_END)"
    endef

    define log-error
    echo -e "$(LOG_ERROR)⇛ $(1)$(LOG_END)"
    endef

    default: build

    ## build: Build the server executable.
    build: code-gen
        $(call log,Building binary...)
        GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) || (\
            $(call log-error,Failed to build $(PROJECTNAME).) \
            && false \
        )

    ## build-linux: Build the server executable in the Linux ELF format.
    build-linux:
        CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make build

    ## code-gen: Generate code before compilation, such as bundled data.
    code-gen: download-dependencies
        $(call log,Generating code...)
        cd data && $(GOBIN)/go-bindata -pkg data . || (\
            $(call log-error,Unable to build data package.) \
            && false \
        )

    ## download-dependencies: Download all library and binary dependencies.
    download-dependencies:
        $(call log,Downloading dependencies...)
        GOPATH=$(GOPATH) GOBIN=$(GOBIN) go mod download
        test -e $(GOBIN)/go-bindata || GOPATH=$(GOPATH) GOBIN=$(GOBIN) go get github.com/kevinburke/go-bindata/...

    .PHONY: clean
    ## clean: Clean up all build files.
    clean:
        @-rm $(OUTBINDIR)/$(PROJECTNAME) 2> /dev/null
        GOPATH=$(GOPATH) GOBIN=$(GOBIN) go clean
        @-rm ./**/bindata.go 2> /dev/null

    .PHONY: help
    all: help
    help: Makefile
        echo
        echo "Choose a command run in "$(PROJECTNAME)":"
        echo
        sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
        echo
    ```

!!! note
    If you're wondering why the `VERSION ?= $(...)` variable has a `?=` instead of a `:=`, that's not a typo! It means that we only assign the variable if it's not already defined.

    I'll explain why this is needed further on in [Section 3](/containerise-it/) where we'll be containerising our application.

!!! tip
    If you are developing an API which is consumer-facing, you'll need to implement some kind of versioning for the API itself so that updating from v1 to v2 doesn't break all of your consumers' applications.

    There are 3 main ways to do this:

    - Versioning using the URI, e.g. https://api.my-org.com/v1 and https://api.my-org.com/v2.
    - Versioning using a custom HTTP header, e.g. `Accept-Version: v1` and `Accept-Version: v2`.
    - Using the standard `Accept` header, e.g. `Accept: application/vnd.mycompany.myapp.myapi-v1+json` and `Accept: application/vnd.mycompany.myapp.myapi-v1+json`.

    Setting this up is outside the scope of this tutorial, but if this is something you need to think about, there's [plenty](https://stackoverflow.com/questions/389169/best-practices-for-api-versioning) of [resources](https://www.xmatters.com/blog/devops/blog-four-rest-api-versioning-strategies/) [online](https://restfulapi.net/versioning/) talking about it and arguing about which one is the Right Way^®^.

We can test to make sure our build version is linked correctly into the API by calling a special `/version` endpoint:

```bash
$ make build
$ ./hbaas-server

# In another terminal
$ curl localhost:8000/version
> {"build_time":"2020-06-01T09:08:38Z","version":"v1.0.0"}
```

!!! success
    With this out the way, we've got our repo in a good starting state to use git flow to complete our first feature!
