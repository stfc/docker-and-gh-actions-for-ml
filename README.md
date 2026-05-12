# Introduction to Docker and GitHub Actions for ML apps - code

This repository contains the code and docs for the "Supercharge your Cloud Development Workflow: Introduction to Docker and GitHub Actions for ML apps" workshop.

To follow along with the workshop, head over to https://supercharge.training.hartree.dev and follow the walkthrough.

The recommended way to follow the tutorial is using GitHub Codespaces to ensure that the development environment is consistent across all attendees - you're welcome to work on your local machine instead, you just need to make sure you install all the necessary dependencies like Docker, Python 3.11 and uv.

## Getting started

If you're using GitHub Codespaces, you should already have all the necessary dependencies installed. If not, make sure you've got [Python 3.11](https://www.python.org/downloads/) and [uv](https://docs.astral.sh/uv/getting-started/installation/) installed:

```bash
python --version
uv --version
```

If not, follow the links above to install them.

Next, create the virtual environment and install the dependencies with uv:

```bash
uv sync
```

Now you're ready to get coding to turn this template into a fully working GPT2-text-generation-as-a-service!

## About the model

The model we're wrapping up as part of the workshop is the [distilgpt2 model](https://huggingface.co/distilgpt2), short for "Distilled GPT-2". This is a distilled (i.e. smaller) version of the GPT-2 model which is itself a precursor to more recent closed-source models such as GPT-3 and GPT-3.5 (the latter being used for Chat-GPT).
