---
title: 0. Setup
---

# 0. :desktop: Setup

## Pre-requisites

As with the previous course, we'll be using the VM (Virtual Machine) on EC2 for our development. The connection details for this should be exactly the same as the previous course - if you don't have these details anymore or you can't access the VM for whatever reason, drop up a line and we'll sort it out.

We recommend a terminal emulator to run SSH through, although you can also access the VM through the EC2 console using your provided login details. Our recommended terminal emulators are:

- macOS - [iTerm2](https://www.iterm2.com/){target="_blank" rel="noopener noreferrer"}
- Windows - [Windows Terminal](https://www.microsoft.com/en-gb/p/windows-terminal/9n0dx20hk701?rtc=1&activetab=pivot:overviewtab){target="_blank" rel="noopener noreferrer"} or [WSL (Windows Subsystem for Linux)](https://docs.microsoft.com/en-us/windows/wsl/install){target="_blank" rel="noopener noreferrer"} for Windows 10, [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html){target="_blank" rel="noopener noreferrer"} for Windows 8 and below.
- Linux - if you're using Linux, you're probably already familiar with your terminal of preference - they all come with one pre-installed anyway, so you can just search for "Terminal" in your apps and it should be there.

## Connecting to VM using SSH

For those new to the terminal, SSH is a program that allows you to securely connect to another machine and run commands on that machine - it's a simple and ubiquitous tool.

You should have been sent the details of the VM created for you for this workshop along with the private key needed to connect to it, alongside your AWS account details. If you don't have any of this information, please do let us know and we'll sort it out for you.

To connect to the VM, simply run:

```bash
# Needed for Linux, macOS & WSL, otherwise SSH server will
# reject your private key.
chmod 600 <path to private key file>

ssh -i <path to private key file> ubuntu@<hostname of your VM>
```

If you're on Linux, macOS or WSL, to make it easy to connect to the VM you can also add an alias in your SSH config:

```bash
echo "Host explain-vm
  User ubuntu
  HostName <hostname of our VM>
  ForwardX11 no
  ForwardAgent yes
  TCPKeepAlive yes
  ServerAliveInterval 120
  PubKeyAuthentication yes
  IdentitiesOnly yes
  IdentityFile <path to private key file>" >> ~/.ssh/config

# Don't need to specify all these details every time now!
ssh explain-vm
```

!!! info
    Your VM hostname should look something like `ec2-52-56-111-13.eu-west-2.compute.amazonaws.com` where `52-56-111-13` will be replaced with the external IP of your particular VM.

!!! warning
    If you see an error like this:

    ![SSH private key permissions error](/images/connecting-to-vm/private-key-permissions-error.png)

    then this means you need to change the permissions on your private key file to `600` (read-only) or `644` (read-write) so that SSH will accept it.

    You can do this by running:

    ```bash
    chmod 600 <path to private key file>
    ```

## Setting up AWS CLI

We're going to be using the AWS CLI to do some cloud resourcing later on in this workshop. Your VM will already have it installed, but you'll need to configure it with the credentials that we sent over to you.

To do this, you need to run the following command and enter the information below, when asked:

```bash
aws configure
```

* AWS Access Key ID - `<your access key id credential>`
* AWS Secret Access Key - `<your secret access key credential>`
* Default region name - `eu-west-2`
* Default output format - `json`

You can double check whether your setup is working correctly by running:

```bash
aws iam get-user | jq
```

If you're all set up correctly you should see something like:

```json
{
    "User": {
        "Path": "/",
        "UserName": "first.last@example.com",
        "UserId": "AIDAQXJVLALMABWIDJRJJ",
        "Arn": "arn:aws:iam::049839538904:user/first.last@example.com",
        "CreateDate": "2021-10-19T11:28:28+00:00",
        "PasswordLastUsed": "2021-11-05T09:38:08+00:00"
    }
}
```

!!! success
    Great! You're all set up and ready to go. Now let's get stuck into some git.
