---
title: 1. Installing dependencies
---

# 1. :construction: Installing dependencies

This tutorial requires the following to be installed:

- git
- make
- Go
- Docker

!!! note "Note on Windows"
    There are a few different routes you can go down for Windows:

    - The best and easiest is to [install the Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Note that is requires admin privileges, and it may take a while to get it all set up.
    - If you can't do this, the next easiest thing to do is install [VirtualBox](https://www.virtualbox.org/) and run an Ubuntu VM through that.
    - You should be able to do everything in this tutorial using PowerShell or cmd[^1]. I've not tried this myself so if you go down this route, please let me know how easy / difficult you find it!

    If you go down either of the first two routes, you should just be following the instructions under "Linux". If you take the latter option, check out the "Windows" tabs for instructions.

[^1]: Don't use cmd though please, every time you open a cmd prompt, you make a Microsoft engineer cry :cry:

## Git

=== "Linux"
    If you're using Linux, you've probably already got git installed. If not, don't worry, it's easy!

    Debian/Ubuntu:
    ```sh
    sudo apt update
    sudo apt install git
    ```

    Fedora / RHEL / CentOS:
    ```sh
    sudo dnf install git
    ```

=== "macOS"
    There are two options for installing git on macOS. You can install the Xcode command line tools or you can install it using Homebrew. I would recommend using Homebrew because installing the Xcode command line tools can take a *long time* if you haven't done it already.

    To install [Homebrew](https://brew.sh), run:
    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

    You can then install git by running:
    ```sh
    brew install git
    ```

    Alternatively, you can install the Xcode command line tools by running:
    ```sh
    xcode-select --install
    ```

    !!! warning
        This can potentially take a while if you haven't done it before!

    Even if you don't use Homebrew to install git, I'd highly recommend installing Homebrew anyway! I'll assume that you've got it installed for the rest of these installation instructions.

=== "Windows"
    To install git on Windows go to: https://git-scm.com/download/win and download & run the setup exe.

## Make

=== "Linux"
    Ubuntu / Debian:
    ```sh
    sudo apt update
    sudo apt install build-essential
    ```

    Fedora / RHEL / CentOS:
    ```sh
    sudo dnf install make
    ```

=== "macOS"
    If you've got Homebrew installed, you should already have make! You can check this:
    ```sh
    which make
    ```

    If you don't for whatever reason or there's a problem, you can run:
    ```sh
    brew install make
    ```
    which will install GNU make as `gmake`, which means you can run `gmake` whenever you would otherwise use `make`.

=== "Windows"
    Go to [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm) and download & run the setup link containing "Complete package, except sources". Once this is installed, you should be able to run `make` from either cmd or PowerShell. (As before, you may need to restart your terminal to reload the `PATH` environment variable.)

## Go

The best thing to do here is follow the instructions at the Golang website: https://golang.org/doc/install.

These are summarised below, but the Golang site has more detailed instructions.

=== "Linux"
    Download the archive from https://golang.org/dl/ and run:
    ```sh
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    ```
    where `$VERSION` is set to the version of Go that you're downloading.

    At the time of writing, that would be:
    ```sh
    export GO_VERSION=1.14.3
    ```

=== "macOS"
    Simply download the pkg file from https://golang.org/dl/ and run it from Finder.

    This will install the Go tools to `/usr/local/go` and add the `/usr/local/go/bin` folder to your `PATH` environment variable. You may need to restart your sessions for this to take effect.

=== "Windows"
    The easiest way to install Go on Windows is to download the MSI installer file from https://golang.org/dl/ and run it. This will install the Go tools to `C:\Go` and add `C:\Go\bin` to the `PATH` environment variable. You may need to restart your cmd / PowerShell for this to take effect.

    You can also manually extract the tools from the zip file (downloadable from the same above link) to wherever you want and add the path `C:\wherever_you_unzipped_the_tools\bin` to your `PATH` environment variable manually.

## Docker

=== "Linux"
    Ubuntu / Debian:
    ```sh
    sudo apt update
    sudo apt install build-essential
    ```

    CentOS:
    ```sh
    sudo yum install make
    ```

=== "macOS"
    Go to https://docs.docker.com/docker-for-mac/install/ and download "Docker Desktop for Mac".

    !!! note
        This requires macOS 10.13 or newer, i.e. High Sierra (10.13), Mojave (10.14) or Catalina (10.15).

=== "Windows"
    Go to https://docs.docker.com/docker-for-windows/install/ and download "Docker Desktop for Windows".

    !!! note
        If you're using the Windows Subsystem for Linux, there's an extra step for you to do to get this working with Windows.

        Go to https://docs.docker.com/docker-for-windows/wsl/ and follow all the instructions there to get Docker Desktop on Windows to use the Linux subsytem within Windows.

        This allows you to run Docker images without any emulation, which is actually pretty clever!

## Please do ask if you get stuck!

If you have any problems installing any of these, please do send us a message so that we can help you get unstuck!
