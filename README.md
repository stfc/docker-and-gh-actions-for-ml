# Go With The Flow Docs

This repository contains the documentation files used to generate the "Go With The Flow" workshop online tutorial website.

## Getting started

- Install Python 3.10 using e.g. pyenv
- Install Poetry

```bash
python -m venv .venv
source ./.venv/bin/activate # Add `.fish` for Fish shell
poetry install

mkdocs serve
```

Then go to http://localhost:8000

## Deploying

To deploy updates, simply push to the `main` branch - the deployment will automatically be handled by Netlify.
