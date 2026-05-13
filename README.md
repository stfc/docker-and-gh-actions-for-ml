# Introduction to Docker and GitHub Actions for ML apps - workshop site

This repository contains the docs used to generate the "Introduction to Docker and GitHub Actions for ML apps" workshop online tutorial site.

## Getting started

Install [uv](https://docs.astral.sh/uv/), then run:

```bash
uv run mkdocs serve
```

Then go to http://localhost:8000

## Deploying

To deploy updates, simply push to the `site` branch - the deployment will automatically be handled by Netlify.

## Updating

There are various dependencies in the code and documentation that should be periodically updated to ensure that the workshop is up to date and recommending latest best practices. Here's a list of things to keep an eye on:

### Python version

The code is currently using Python 3.11 because that's the latest that PyTorch officially recommends, although they seem to be deploying packages for 3.12. As new Python versions are released, we should update the code to use the latest stable version supported by PyTorch.

Updating

### Python dependencies

It's a good idea to periodically update the project dependencies to the latest version. The easiest way to do this is to run `uv pip list --outdated` and then manually updating the version constraints in the `pyproject.toml` to the latest version.

### GitHub Actions

There are a few actions that are used in the docs that should be periodically checked for updates. These are:

- [`actions/checkout`](https://github.com/actions/checkout){target=_blank} (currently **@v6**)
- [`astral-sh/setup-uv`](https://github.com/astral-sh/setup-uv){target=_blank} (currently **08807647e7069bb48b6ef5acd8ec9567f424441b**  – v8.1.0)
- [`docker/login-action`](https://github.com/docker/login-action){target=_blank} (currently **@v4**)
- [`docker/metadata-action`](https://github.com/docker/metadata-action){target=_blank} (currently **@v6**)
- [`docker/build-push-action`](https://github.com/docker/build-push-action){target=_blank} (currently **@v7**)

Most of these actions seem to be stable in terms of the parameters and whatnot and the major version updates indicate a bump in the Nodejs runtime that is being used, but it's best to scan through the documentation / releases to check that there are no breaking changes for us.
