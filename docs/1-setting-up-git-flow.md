---
title: 1. Setting up git flow
---

# 1. :twisted_rightwards_arrows: Setting up git flow

## Git flow

The branching model we're going to be using is the following:

![git flow branching model](images/git-flow.png)

This is a very common and very popular branching model (although many people adapt or extend it).

The main important info about this branching model to bear in mind when thinking about how the git repository represents the service you're building is:

- The `master` branch always represents the *production-ready*, released version of the code.
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

With this out the way, we've got our repo in a good starting state to use git flow for our future development.
