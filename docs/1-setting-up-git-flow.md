---
title: 1. Setting up git flow
---

# 1. :twisted_rightwards_arrows: Setting up git flow

## Git flow

The branching model we're going to be using is the following:

![git flow branching model](/images/setting-up-git-flow/git-flow.png)

Now, there's a lot going on in this diagram if you haven't seen it before, so don't panic if this doesn't make much sense to you - we're going to be going through it in practice step-by-step so hopefully this will make more sense to you by the end of this tutorial.

The main important things to know about this are:

- The `master` branch always represents the _production ready_, released version of the code.
- All merges into the `master` branch should be tagged with the version number, according to the [Semantic Versioning (SemVer)](https://semver.org/){target="_blank" rel="noopener noreferrer"} standard.
- The `dev` branch represents the current tip of the development effort for your code. It should contain the latest updates in a working state (but if your dev branch is broken for a while, it's not a big deal).
- No work should be done directly on the `dev` or `master` branches - instead, they should be branches out, completed and then merging back in (preferably after a pull request and peer review).
- Features and non-urgent bug fixes should be branched from the `dev` branch.
- Urgent bug fixes (a.k.a. hotfixes) that need to be immediately updated on the production code should be branched from the `master` branch, and merged into both the `master` and `dev` branches when ready.

This particular branching model, known commonly as "git flow", is a very popular choice (although many adapt or extend it).

## Quick explanation of SemVer

Some of you might not have encountered Semantic Versioning or SemVer before - the basic idea is super simple (although you wouldn't think so looking at the full specification).

Each version has 3 numbers, separated by full-stops, and an optional label at the end, like this:

![SemVer Demo](/images/setting-up-git-flow/semver.png)

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

## What makes a good commit?

Before we dive into our practical exercise, it's worth first talking about what makes a particular git commit _good_, and what makes one _bad_.

It's sometimes tempting to use commit messages like "updated /hello endpoint" or "Changes to backend", but really these messages don't convey a lot of information that's really useful to someone trying to understand what's going on in a repository.

Here are a few tips on creating the most useful commit messages you can:

- **Be specific** - If someone reads a commit that says "changes to backend", the first thing we want to know is: what changes did you make! By being as specific as possible, it makes it massively easier to trace back through a commit history and find where a particular feature was added (or conversely where it was broken!). For an example of this, think about "Add date filtering to /hello endpoint". Now someone who's wondering why the date filtering isn't working can look through the history and immediately pick out the commit that they need!
- **Explain intent** - We can see into the commit and look at what files you changed and how - the important thing to get across in your commit message is _why_ you made the changes that you did. For instance, instead of saying "Changes to backend"
- **Be consistent** - It's not particularly important which specific format you use for your commits. whether you choose to phrase your commits like "Add x to y" or "Added x to y" (although there are endless debates online) doesn't really make any change anything about anything! As with the code itself, the important thing is to be consistent - choose an approach and stick to it (and make sure that other people stick to it as well).
- **When appropriate, include extra detail** - There's a standard format for git commits. They look like this:

    ```git
    Add date filtering to /hello endpoint.

    Now you can pass in `start_date` or `end_date` as query parameters to the `/hello`
    endpoint and the results will be filtering accordingly.
    ```

    While the first line should be a brief summary of the changes, you can add additional info including a full description or any other salient points - simply add an empty line after the first one and put your description after that.

## Cloning the repo

Now that we've got the theory out the way, let's get started!

First things first, let's clone the repository containing the code that we'll be working with for this tutorial, and get it set up on our system.

```bash
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

```bash
# Remember to replace '{my-username}' with your GitLab username.
git remote set-url origin https://gitlab.com/{my-username}/go-with-the-flow-code.git

# You can double check that your origin is pointing to the right location like so:
git remote -v
```

where `{my-username}` is your GitLab username.

## Setting up our branches

We only have the `tutorial/section-X` branches right now - not even a master branch! That's the first thing we'll need to create.

```bash
git checkout -b master
git push --set-upstream origin master
```

Great. Now that we've got a master branch, let's tag out very first release:

```bash
git checkout master
git tag -a v1.0.0 -m "Release v1.0.0 - Initial app launch."
git push --tags
```

!!! info "Code signing tags"
    In generic, I would very much recommend creating a GPG key and signing your commits and tags using that key. You can then upload your public GPG key to GitLab to show whether your commits and tags are verified.

    Having an expectation of signing your git activity is a really good position to be in from a security perspective.

    If you do want to sign your tags, you simply run:

    ```bash
    git tag -s v1.0.0
    ```

    While code signing is thoroughly recommended, setting up the relevant keys is outside the scope of this tutorial.

    For more information, GitHub has [plenty of info on GPG and git](https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key){target="_blank" rel="noopener noreferrer"}.

Next, let's create our `dev` branch.

```bash
git checkout -b dev
git push --set-upstream origin dev
```

## GitLab default branch

One last thing you'll want to do before moving on - the GitLab repository has a default remote branch - you'll want to change this to either dev or master.

I usually put dev as the default branch as it makes it the default target for merge requests, but making master your default branch is a perfectly reasonable choice too, as it represents the most up-to-date release of your project.

To do this, go to "Settings" > "Repository" > "Default Branch":

![choosing default branch](/images/setting-up-git-flow/default-branch.png)

## Getting the API version

We want to be able to get the version of our app automatically, without needing to manually modify a file each time we want a new version.

Well there's good news - we can get this out of git automatically!

If you've set up your git flow and you're on either your master or dev branches, we can get our current version in semver format by simply running:

```bash
git describe --tags --always
```

!!! info
    To make sure that `git describe` always gives you the correct information on both master and dev branches, there's a slight modification required to the git flow. That is, once you've merged dev into the master branch and tagged the release, you should merge back into the develop branch. Also, all merges should be done using `--no-ff` which ensures that merges always create a commit.

    What this does is ensure that the tagged commit (i.e. the merge into master) is present on both master and dev, which ensures that git can accurately get the version from both branches.

!!! tip
    Git will automatically add an extra bit to the version number based on how many commits ahead you are, which takes the place of the optional pre-release label.

    For instance, if you were on version 0.6.3 but then made 2 commits on top, you would get out something like:

    ```bash
    git describe --tags --always
    > v0.6.3-2-g1a64609
    ```

    Here the `2` indicates that we are 2 commits ahead of tag `v0.6.3` and the `g1a64609` is the shortened hash of the commit that we're on.

Now, we've already got some [clever linking](https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications){target="_blank" rel="noopener noreferrer"} going on in the app so we can check whether we've correctly set up our branching model using the app itself! All we need to do is make a request to the special `/version` endpoint:

```bash
make build
./hbaas-server

# In another terminal:
curl localhost:8000/version
> {"build_time":"2020-06-01T09:08:38Z","version":"v1.0.0"}
```

!!! tip
    If you are developing an API which is consumer-facing, you'll need to implement some kind of versioning for the API itself so that updating from v1 to v2 doesn't break all of your consumers' applications.

    There are 3 main ways to do this:

    - Versioning using the URI, e.g. https://api.my-org.com/v1 and https://api.my-org.com/v2.
    - Versioning using a custom HTTP header, e.g. `Accept-Version: v1` and `Accept-Version: v2`.
    - Using the standard `Accept` header, e.g. `Accept: application/vnd.mycompany.myapp.myapi-v1+json` and `Accept: application/vnd.mycompany.myapp.myapi-v1+json`.

    Setting this up is outside the scope of this tutorial, but if this is something you need to think about, there's [plenty](https://stackoverflow.com/questions/389169/best-practices-for-api-versioning){target="_blank" rel="noopener noreferrer"} of [resources](https://www.xmatters.com/blog/devops/blog-four-rest-api-versioning-strategies/){target="_blank" rel="noopener noreferrer"} [online](https://restfulapi.net/versioning/){target="_blank" rel="noopener noreferrer"} talking about it and arguing about which one is the Right Way^®^.

!!! success
    With this out the way, we've got our repo in a good starting state to use git flow to complete our first feature!
