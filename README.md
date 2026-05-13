# Introduction to Docker and GitHub Actions for ML apps - code

This repository contains the code and docs for the "Supercharge your Cloud Development Workflow: Introduction to Docker and GitHub Actions for ML apps" workshop.

To follow along with the workshop, head over to https://supercharge.training.hartree.dev and follow the walkthrough.

The recommended way to follow the tutorial is using GitHub Codespaces to ensure that the development environment is consistent across all attendees - you're welcome to work on your local machine instead, you just need to make sure you install all the necessary dependencies like Docker and uv.

## Getting started

If you're using GitHub Codespaces, you should already have all the necessary dependencies installed. If not, make sure you've got [uv](https://docs.astral.sh/uv/getting-started/installation/) installed and run:

```bash
uv sync
```

Now you're ready to get coding to turn this template into a fully working GPT2-text-generation-as-a-service!

## About the model

The model we're wrapping up as part of the workshop is the [distilgpt2 model](https://huggingface.co/distilgpt2), short for "Distilled GPT-2". This is a distilled (i.e. smaller) version of the GPT-2 model which is itself a precursor to more recent closed-source models GPT-3 up to GPT-5.5.
