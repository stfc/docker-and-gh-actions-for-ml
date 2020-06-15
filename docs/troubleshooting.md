---
title: Troubleshooting
---

# :bug: Troubleshooting

## `Authentication failed. Unable to refresh auth token: Remote server error.`

If you see the following error when running IBM Cloud commands:

```
`Authentication failed. Unable to refresh auth token: Remote server error. Status code: 401, error code: invalid_token, message: Invalid refresh token expired at Thu Jun 11 13:49:34 UTC 2020. Try again later.
```

Then this means that your IBM Cloud login has expired and you need to re-log in using:

```bash
ibmcloud login --sso
```

## `yaml: line 3: did not find expected '-' indicator`

If you get the above error when running `make deploy-dev`, it's a sign that the indentation on your `manifest.yaml` is incorrect.

In particular, it's important that the `-` that comes before each application block is indented like so:

```yaml
applications:
  # Notice how there are two spaces before the `-` character here
  - name: hbaas-server-dev

    # Here, however, there are 4 spaces.
    instances: 1
    memory: 1GB
    ...

  # Again, there are two spaces here
  - name: hbaas-server-prod

    # And 4 spaces here
    instances: 1
    memory: 1GB
    ...
```

## `Could not get space: Space '{some-value}' was not found.`

You may see the following when running `make deploy-dev` or `make deploy-prod`:

```
FAILED
Could not get space:
Space '{some-value}' was not found.

make[1]: *** [deploy-app] Error 1
make: *** [deploy-dev] Error 2
```

This indicates that the value that you put for the `CFSPACE` is not correct. You can check what spaces are available from the command line via:

```bash
# After running this, you need to interactively choose the correct options for this training
ibmcloud cf --target

ibmcloud cf spaces
```

If you don't have any spaces available to you, please contact one of us so that we can get it set up.

## `You have exceeded your organization's memory limit: app requested more memory than available`

The free version of IBM Cloud has restrictions around things like memory usage for IBM Cloud apps.

If you're pointing to your personal IBM Cloud account, you may see the above error when you run `make deploy-dev`. Make sure that you're pointing to the account and workspace set up for you to complete this tutorial, which should not have any issues with memory limits.

You can make sure that you're pointing to the correct environment and change the environment is necessary by running:

```bash
ibmcloud target --cf
```

This will interactively walk you through the various Cloud Foundry environment options.

## `/bin/bash: -c: line 1: syntax error: unexpected end of file`

If you see the following when trying to run any `make` commands:

```
/bin/bash: -c: line 1: syntax error: unexpected end of file
make: *** [{make command you tried to run}] Error 2
```

Then you may have trailing whitespace interfering with the Makefile. If you're using VS Code, you can do "Ctrl + Shift + P" (or "Cmd + Shift + P" on macOS) and type "Trim Trailing Whitespace".

If you're not using VS Code, try looking through all the lines to see whether you've accidentally left any trailing spaces.

## `Makefile:115: *** missing separator. Stop.`

If you see the above error when trying to run a `make` command, it indicates that you're indenting for one or multiple of the targets is incorrect.

The indenting for Makefile is very particular. If you look at a simple target:

```Makefile
do-thing:
	run-some-command \
	    --option-one $(VALUE_ONE) \
	    --option-two $(VALUE_TWO)
```

You can see how the first indent is a hard tab - `	` - while the further indentation is done using spaces. Make is sensitive to this different - the initial indent should be a hard tab and that tells make that the hard-tab indented code in what should be run for that target (i.e. command). The spaces after that initial hard-tab are there just to make the long command look prettier so should be indented using soft spaces - ` `.
