# Introduction to Docker and GitHub Actions for ML apps - workshop site

This repository contains the docs used to generate the "Introduction to Docker and GitHub Actions for ML apps" workshop online tutorial site.

## Getting started

- Install Python 3.x using e.g. pyenv (Netlify uses 3.8 but anything 3.8+ should work).
- Install Poetry

```bash
python -m venv .venv
source ./.venv/bin/activate # Add `.fish` for Fish shell
poetry install

mkdocs serve
```

Then go to http://localhost:8000

## Deploying

To deploy updates, simply push to the `site` branch - the deployment will automatically be handled by Netlify.

## Updating

There are various dependencies in the code and documentation that should be periodically updated to ensure that the workshop is up to date and recommending latest best practices. Here's a list of things to keep an eye on:

### Python version

The code is currently using Python 3.11 because that's the latest that PyTorch officially recommends, although they seem to be deploying packages for 3.12. As new Python versions are released, we should update the code to use the latest stable version supported by PyTorch.

Updating

### Poetry dependencies

It's a good idea to periodically update the Poetry dependencies to the latest version. The easiest way to do this is to run through all the dependencies listed in the main deps sectino and the dev group and to run `poetry install dep1@latest dep2@latest` etc. to update them all. You need to do this once for the main group of deps and once for the dev group via `poetry install --group dev devdep1@latest devdep2@latest`.

There's also the PyTorch dependencies. Poetry has a thing where if you add a custom package index, Poetry needs to download all packages from the index to determine the relevant versions. This means that adding the custom PyTorch package index will cause the package scan to take ~30 minutes or so.

Instead, we manually add the direct link to the wheels in the pyproject.toml. The filenames here need manually updating when the Python version changes, i.e. updating Python v3.10 to v3.11 would mean changing `https://download.pytorch.org/whl/cpu/torch-2.4.0%2Bcpu-cp310-cp310-linux_x86_64.whl` to `https://download.pytorch.org/whl/cpu/torch-2.4.0%2Bcpu-cp311-cp311-linux_x86_64.whl`. (The `cp310` means "CPython 3.10".) This needs to be done manually for each platform.

### GitHub Actions

There are a few actions that are used in the docs that should be periodically checked for updates. These are:

- [`actions/checkout`](https://github.com/actions/checkout){target=_blank} (currently **@v4**)
- [`actions/setup-python`](https://github.com/actions/setup-python){target=_blank} (currently **@v5**)
- [`docker/login-action`](https://github.com/docker/login-action){target=_blank} (currently **@v3**)
- [`docker/metadata-action`](https://github.com/docker/metadata-action){target=_blank} (currently **@v5**)
- [`docker/build-push-action`](https://github.com/docker/build-push-action){target=_blank} (currently **@v6**)

Most of these actions seem to be stable in terms of the parameters and whatnot and the major version updates indicate a bump in the Nodejs runtime that is being used, but it's best to scan through the documentation / releases to check that there are no breaking changes for us.
