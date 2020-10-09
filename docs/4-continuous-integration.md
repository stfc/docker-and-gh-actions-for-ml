---
title: 4. Setting up continuous integration
---

# 4. :white_check_mark: Setting up continuous integration

Next, we're going to leverage the power of continuous integration to take a bunch of work off our hands and generally make our lives easier.

## What's continuous integration all about?

In short, continuous integration (or CI) just means setting up a computer to run automatic checks over your code every time you upload a commit to your repository.

This is a super simple idea but can bring a lot of power and versatility to your project workflow. Not only will CI check common mistakes and typos for you, it can provide a history of builds and documentation so that you can track down any bugs you find to the exact commit that caused them.

## Continuous integration solutions

There are a bunch of different CI tools out there. Here's a quick overview of the most popular:

### GitLab CI

![GitLab CI / CD](/images/continuous-integration/gitlab-ci-cd.png){: style="height: 200px; float: right;"}

GitLab CI is what we're going to be using for this demo for a few reasons:

- GitLab is an incredibly popular tool for companies hosting their own version control system. This makes it prevelant in business which don't want their IP-sensitive company code on a publicly hosted systems.
- GitLab CI comes built into GitLab - all you need to do to set up a Runner (i.e. computer which runs our pipelines) is run a simple script.
- GitLab CI is free to use on the publicly hosted [gitlab.com](https://gitlab.com){target="_blank" rel="noopener noreferrer"} GitLab instance and works out of the box without needing to install, setup or enable anything whatsoever. This means that it's both free and easy to use for this tutorial.

Overall, GitLab CI is a very sophisticated, well designed and battle-hardened CI solution.

### GitHub Actions

![GitHub Actions](/images/continuous-integration/github-actions.jpg){: style="height: 200px; float: right; margin: 0 0 15px 15px;"}

GitHub Actions is the new kid on the block here - it started its public beta a few months ago and it now available for widespread use.

Admittedly, it's become fairly popular in the few months that it's been around, but it's still in it's early stages[^1]. It's being used in production by big companies already, but it's not as well established as the big players like GitLab CI, CircleCI and TravisCI.

One of the big advantages of GitHub Actions is that because it's built into GitHub, you can fork a repository and have the CI _just work_ on your fork (excluding any secret variables). This is actually pretty powerful! This same advantage also applied to GitLab, but GitHub remains the go-to solution for open source code and many proprietary codebases.

[^1]: A case in point here is that GitHub Actions configuration files changed entirely from using a domain-specific language (DSL) to using YAML (like all the other CI solutions), which means searching around for documentation still brings up the old DSL solution instead of the new YAML solution.

Something that sets GitHub Actions apart from all the competitors is it's support for code annotations that will label issues with your code directly in the pull request, which is a pretty useful feature.

This and the ability to leverage pipelines other people have written (via the [GitHub Marketplace](https://github.com/marketplace?type=actions){target="_blank" rel="noopener noreferrer"}) to made your CI configuration easier means that Actions will likely be used more and more over the next few years, especially for open source projects.

### Jenkins

![Jenkins](/images/continuous-integration/jenkins.png){: style="height: 200px; float: right;"}

Jenkins is, like DroneCI, designed to be hosted by the consumer themselves. Compared to all the others, it is the ancient behemonth, hardened by years of heavy use.

It's a large, lumbering project which predates many things like containers and infrastructure-as-code.

For this reason, it's largely lagged behind in terms of functionality, but makes up for it by having an enormous ecosystem of plugins. Because Jenkins has been around for so long and has been used by so many people, there's a plugin for pretty much anything you might want to do.

This does mean that it doesn't provide out-of-the-box support for many things, and in my experience it's a lot more effort to maintain and configure, but it's certainly stable product with many years of battle experience under it's belt.

### TravisCI

![TravisCI](/images/continuous-integration/travis-ci.png){: style="height: 200px; float: right;"}

TravisCI was one of the first CI solutions out there. It used to be the market leader by a long way, and you'd find almost all open source projects using TravisCI, as well as lot's of proprietary projects.

It's certainly well used, well loved and well established, but it doesn't have the dominance that it once did. More and more GitHub projects are moving over to GitHub Actions or CircleCI instead of TravisCI, but it still remains a solid option!

### CircleCI

![CircleCI](/images/continuous-integration/circle-ci.png){: style="height: 200px; float: right;"}

CircleCI is similar to TravisCI is many ways, with two important differences:

- While there's a fully hosted version, you can always run your own CircleCI server
- CircleCI has a free plan available to closed-source projects

Other than that, there's not much more to say! The configuration is slightly different to TravisCI (but still YAML) and it doesn't have the same build matrix options that TravisCI has.

Regardless, CircleCI remains a very popular choice for it's relative cheapness, easy of use and ability to move onto self-hosted servers now or at a later date without any frictions or conversion required.

### DroneCI

![DroneCI](/images/continuous-integration/drone-ci.png){: style="height: 200px; float: right;"}

DroneCI is a another new kid on the block. It's a self-hosted solution designed to be container-native from the offset - everything runs in containers, from the jobs to the DroneCI server to the job runners.

Like almost all the others (looking at you Jenkins), it uses a simple YAML format for the configuration. There's a tool to convert GitLab CI configs into DroneCI configs (although in my experience the conversion misses out many of the features of the original).

DroneCI is a very simple and slick solution that's good if you want to be able to quickly set up a CI server and forget about it from then on. There's basically zero required (or even possible) system configuration, which makes it excellent for simple tasks, but lacking flexibility for complex custom workflows. Then again, there's always an API for you to use if you want to build out your own custom CI code around the DroneCI API...

## Time to clear out the lint

The first thing we're going to want to do in our continuous integration is _lint_ our code. This means automatically checking to make sure it is correctly formatted and doesn't fall victim to common programming mistakes.

In Go, the most popular tool for CI linting is [golangci-lint](https://golangci-lint.run){target="_blank" rel="noopener noreferrer"} - this combines a bunch of different checkers into one single tool which is easy to install in CI pipelines. It'll check for common programming mistakes, style inconsistencies and it'll verify whether we've remember to run `go fmt` to automatically format our code.

To get started with our CI, we first have to make our `.gitlab-ci.yml` file:

!!! example "`.gitlab-ci.yml`"
    ```yaml linenums="1"
    image: golang

    cache:
      key: ${CI_COMMIT_REF_SLUG}
      paths:
        - .go-bin
        - .go-pkg

    # Each stage runs consecutively, one after the other. Each stage can have multiple
    # jobs running in it.
    stages:
      - lint

    # This is a single job, called 'lint', running in the 'lint' stage.
    lint:
      stage: lint
      before_script:
        - wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.27.0
        # We need to run the code-gen scripts for the linting to work.
        - make code-gen
      script:
        - golangci-lint run --enable gofmt --enable goimports
    ```

!!! tip
    Notice how we're specifying a cache in this YAML file - this ensures that the Go dependencies are all cached in between each CI run, which will massively speed up how long it takes to complete your CI pipelines.

If you commit this file and push it up to your GitLab repo, and go to "CI / CD" > "Pipelines" in the bar along the left, you should see our CI pipeline running for the first time!

![lint pipeline list](/images/continuous-integration/lint-pipeline-list.png)

If you click on the individual pipeline that just ran, you can see a visualisation of our pipeline, along with the output of all the commands.

But alas, our pipeline has an error in it! If you go into the the output of the lint job you should be able to see what the error is:

![lint pipeline error](/images/continuous-integration/lint-pipeline-error.png)

Based on this, we can see that we have a string that is inside a call to `fmt.Sprintf()`, but which doesn't have any formatting applied to it. A silly mistake which can be easily remedied:

!!! example "`handlers/birthday.go`"
    ```go linenums="21" hl_lines="4"
    }

    func (h BirthdayHandler) sayHello(c echo.Context) error {
    	message := "Welcome! Try sending a request to '/{some-name}' to get started!"
    	return c.JSON(
    		http.StatusOK,
    		NewAPIMessage(message),
    ```

If you commit this fix and push your change, you should get that lovely nice green tick:

![line pipeline fix](/images/continuous-integration/lint-pipeline-fix.png)

## Let's make sure our code builds

Now that we've got a basic CI pipeline set up to lint our code, we've already got a pretty big safety net to prevent uncaught mistakes getting into our codebase.

But we can do better.

Let's start by adding another stage to our pipeline to build our code. This'll happen just after our 'lint' stage:

!!! example "`.gitlab-ci.yml`"
    ```yaml linenums="1" hl_lines="11 22-26"
    image: golang

    cache:
      key: ${CI_COMMIT_REF_SLUG}
      paths:
        - .go-bin
        - .go-pkg

    stages:
      - lint
      - build

    lint:
      stage: lint
      before_script:
        - wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.27.0
        # We need to run the code-gen scripts for the linting to work.
        - make code-gen
      script:
        - golangci-lint run --enable gofmt --enable goimports

    build:
      stage: build
      script:
        - make build
    ```

Now we can see our CI pipeline has an extra stage in it for our build, which as expected is succeeding:

![build stage success](/images/continuous-integration/build-stage-success.png)

We can do better than this though - we can 'artifact' the output of the build so that we have a downloadable history of the state of the built application after every single commit.

This is _super_ useful for regressing bugs because you can run the application after every single commit and find which commit introduced the bug. Here's how we do it:

!!! example "`.gitlab-ci.yml`"
    ```yaml linenums="1" hl_lines="26-30"
    image: golang

    cache:
      key: ${CI_COMMIT_REF_SLUG}
      paths:
        - .go-bin
        - .go-pkg

    stages:
      - lint
      - build

    lint:
      stage: lint
      before_script:
        - wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.27.0
        # We need to run the code-gen scripts for the linting to work.
        - make code-gen
      script:
        - golangci-lint run --enable gofmt --enable goimports

    build:
      stage: build
      script:
        - make build
      artifacts:
        paths:
          - hbaas-server
        # You can choose how long you want your builds to stick around for.
        expire_in: 30 days
    ```

!!! tip
    GitLab CI also supports natively displaying the [results of unit tests](https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html#artifactsreportsjunit){target="_blank" rel="noopener noreferrer"}. If you're testing your software (which is almost always a really good idea) then you can use this same `artifact` to collect unit testing reports.

    These unit tests will also be shown in merge requests so that you can check over them before merging feature or fixes into your dev branch.

Now if you go to the "CI / CD" > "Pipelines" page, you should have a dropdown allowing you to download your built application executable as a file called `artifacts.zip` - decompress this and you'll get your `hbaas-server` exe for that commit.

## Let's build, tag and upload our images automatically!

Now that we've got lint and build stages set up, we can build and upload our image to the private repository we created in [Section 3](/containerise-it/).

As we need to have access to our private repository, we need to get an API key from IBM Cloud and put it into the "secrets" in GitLab. This means that when we do `ibmcloud login`, the IBM Cloud CLI takes our API key from the runner environment and uses it to authenticate against the IBM Cloud so that it can upload our image. Neat!

First things first, let's get our API key from IBM Cloud.

You can do this [using the IBM Cloud website](https://cloud.ibm.com/docs/iam?topic=iam-userapikey#create_user_key), but we're going to use the CLI because it's easier and faster:

```bash
ibmcloud iam api-key-create GitLabCIKey -d "API key for GitLab CI / CD." --file gitlab_ci_key.json
```

If you look in the output `gitlab_ci_key.json` file, you should see something like this:

!!! example "`gitlab_ci_key.json`"
    ```json linenums="1"
    {
        "id": "ApiKey-01234567-89ab-cdef-0123-456789abcdef",
        "crn": "crn:v1:bluemix:public:iam-identity::a/0123456789abcdef0123456789abcdefA-1234567A::apikey:ApiKey-01234567-89ab-cdef-0123-456789abcdef",
        "iam_id": "IBMid-0123456789",
        "account_id": "0123456789abcdef0123456789abcdef",
        "name": "GitLabCIKey",
        "description": "API key for GitLab CI / CD.",
        "apikey": "abcdefghijk-lmnopq_rstuvwxy-zABCDEFGH_IJKLMN",
        "locked": false,
        "entity_tag": "1-0123456789abcdef0123456789abcdef",
        "created_at": "2020-06-02T10:37+0000",
        "created_by": "IBMid-0123456789",
        "modified_at": "2020-06-02T10:37+0000"
    }
    ```

The important thing here is the `apikey` field - this is what we want! The rest is just bits of metadata.

We need to copy this `apikey` value and put it into the "Variables" section under "Settings" > "CI / CD", like so:

![GitLab CI secrets](/images/continuous-integration/gitlab-ci-secrets.png)

!!! note
    If you're using an older hosted version of GitLab, this UI will look slightly different, and the section will be called "Secrets" instead of "Variables" - the outcome is the same, though!

It's important that you call the key `IBMCLOUD_API_KEY` precisely, otherwise the IBM Cloud CLI will not pick it up. For the value, simply paste in the `apikey` from above.

!!! tip
    If you're not seeing the environment variable show up in your CI pipeline, check whether the "Protected" flag is set in the CI settings. If this is set, the variable is only available to branches which are "protected".

    By default, only `master` is protected, which means you have to either protect the `dev` branch in "Settings" > "Repository" or untick the "Protected" box on the variables settings page.

    In general, it's a good idea to keep your `master` and `dev` branches protected because it prevents rewriting history, but this is up to your individual use-case.

Once you've done this, we can update our GitLab CI YAML to add an extra stage for our Docker stuff and add a job that will upload a Docker image every time a commit is pushed to the `dev` or `master` branches:

!!! example "`.gitlab-ci.yml`"
    ```yaml linenums="1" hl_lines="3-23 34 54-70"
    image: golang

    variables:
      # When using dind service we need to instruct docker, to talk with the
      # daemon started inside of the service. The daemon is available with
      # a network connection instead of the default /var/run/docker.sock socket.
      #
      # The 'docker' hostname is the alias of the service container as described at
      # https://docs.gitlab.com/ee/ci/docker/using_docker_images.html#accessing-the-services
      #
      # Note that if you're using the Kubernetes executor, the variable should be set to
      # tcp://localhost:2375 because of how the Kubernetes executor connects services
      # to the job container
      # DOCKER_HOST: tcp://localhost:2375
      #
      # For non-Kubernetes executors, we use tcp://docker:2375
      # DOCKER_HOST: tcp://docker:2375
      #
      # This will instruct Docker not to start over TLS.
      DOCKER_TLS_CERTDIR: "/certs"

    services:
      - name: docker:19.03.1-dind

    cache:
      key: ${CI_COMMIT_REF_SLUG}
      paths:
        - .go-bin
        - .go-pkg

    stages:
      - lint
      - build
      - docker

    lint:
      stage: lint
      before_script:
        - wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.27.0
        # We need to run the code-gen scripts for the linting to work.
        - make code-gen
      script:
        - golangci-lint run --enable gofmt --enable goimports

    build:
      stage: build
      script:
        - make build
      artifacts:
        paths:
          - hbaas-server
        expire_in: 30 days

    upload-image:
      stage: docker
      image: docker:19.03.1
      before_script:
        - apk add --update alpine-sdk bash
        - curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
        - ibmcloud plugin install container-registry -r 'IBM Cloud'
        # Latest CF is not compatible with IBM Cloud (seemingly) because the IBM Cloud CF
        # instance doesn't have log cache installed on it.
        - ibmcloud cf install --version 6.49.0 --force
        - ibmcloud login --no-region
        - ibmcloud cr region-set uk-south
      script:
        - make upload-image
      only:
        - dev
        - master
    ```

!!! note
    You might notice that we had to use a separate image for the upload job, and that we need to add a variable and service to the config.

    This is because the job is running inside a Docker image, which means we need to allow the Docker in the job inside the container to contact the Docker daemon running outside the container. This is known as d-in-d or Docker-in-Docker.

Commit and push this change to your GitLab repo and you should see your images built, tagged and uploaded to your private repository.

![upload image CI pipeline](/images/continuous-integration/upload-image-ci-pipeline.png)

This'll work regardless of whether it's running on `dev` or `master` - you don't want this running on other branches, otherwise you'll end up with images in your private repository from your feature and bugfix branches cluttering up your private registry.

!!! note
    Building images for your feature and bug fix branches can be a really powerful and useful tool to use in combination with continuous deployment for allowing you to automatically host test environments for new features.

    This would be part of a much more complex and sophisticated CI / CD setup, so isn't in scope of this tutorial.

!!! tip
    Making the CI play nicely with the IBM Cloud private repository can be fernickity so please do reach out if you encounter any problems here!

If you check your "upload-image" job in GitLab, you should see an output that looks something like this:

![image upload job output](/images/continuous-integration/image-upload-job-output.png)

You can check to make sure that your images have uploaded properly by checking the GitLab CI job logs and by running:

```bash
ibmcloud cr images
> Listing images...
>
> Repository                                     Tag                                Digest         Namespace               Created          Size     Security status
> uk.icr.io/my-org/hbaas-server                  latest                             135777eaee3a   my-org                  12 minutes ago   13 MB    No Issues
> uk.icr.io/my-org/hbaas-server                  v1.0.0-16-g232c588                 a4ba15b7e419   my-org                  2 days ago       13 MB    No Issues
```

!!! success
    With this completed, you've now got your continuous integration pipeline set up! Congratulations!

    In the next chapter we're going to use this pipeline and extend it to deploying our applications as well as just building them.
