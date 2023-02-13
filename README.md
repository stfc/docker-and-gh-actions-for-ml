# Introduction to Docker and GitHub Actions for ML apps - code

This repository contains the code and docs for the "Supercharge your Cloud Development Workflow: Introduction to Docker and GitHub Actions for ML apps" workshop.

To follow along with the workshop, head over to https://supercharge.training.hartree.dev and follow the walkthrough.

The recommended way to follow the tutorial is using GitHub Codespaces to ensure that the development environment is consistent across all attendees - you're welcome to work on your local machine instead, you just need to make sure you install all the necessary dependencies like Docker, Python 3.10 and Poetry.

## Getting started

If you're using GitHub Codespaces, you should already have all the necessary dependencies installed. If not, make sure you've got [Python 3.10](https://www.python.org/downloads/) and [Poetry](https://python-poetry.org/docs/#installation) installed:

```bash
python --version
poetry --version
```

If not, follow the links above to install them.

Next, create a virtual environment and install the dependencies with Poetry:

```bash
python -m venv .venv
source ./.venv/bin/activate
```

Now you're ready to get coding to turn this template into a fully working GPT2-text-generation-as-a-service!
