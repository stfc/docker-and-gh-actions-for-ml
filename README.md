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
