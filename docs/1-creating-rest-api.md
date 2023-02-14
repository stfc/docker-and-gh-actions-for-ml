---
title: 1. Creating our model API
---

# 1. :robot: Creating our model API

First, we're going to wrap up our GPT-2 model in a nice RESTful API. Let's get stuck in.

## What's our model?

We're starting from an existing model here, so what exactly is it?

You can view the model card on Hugging Face here: https://huggingface.co/distilgpt2

In short, it's an NLP (Natural Language Processing) model that is a distilled (i.e. smaller) version of OpenAI's [GPT-2 model](https://openai.com/blog/gpt-2-1-5b-release/). We're using it as a fun and interactive model to use as a starting point for our exercises - it could be any model really, but this one is quite fun to play around with.

!!! info "What's the difference between GPT-2 and ChatGPT?"
    [ChatGPT](https://openai.com/blog/chatgpt/) is part of the same research efforts by OpenAI, but it uses a fine-tuned version of the [GPT-3.5 model](https://platform.openai.com/docs/model-index-for-researchers), which means it is 2 steps ahead of our model. The [GPT-3](https://openai.com/blog/gpt-3-apps/), GPT-3.5 and [ChatGPT](https://openai.com/blog/chatgpt/) models, unlike GPT-2, are closed source which means we can't download them and use them ourselves - we have to use OpenAI's own API to access them.

    The GPT-3 and GPT-3.5 models use colossally more parameters than GPT-2 which uses more than our distilled GPT-2 (GPT-3 has 175 billion parameters, GPT-2 has 1.5 billion and our distilled GPT-2 has 82 million), which is how they're able to give answers that are much more sophisticated. GPT-2 is still great for playing around with though - our model is only 350 MB while GPT-3 clocks in at an impressive 800 GB!

!!! question "Where is the model?"
    If you're looking at the code repository that we just forked, you might be thinking - "where is this ML model? I don't see it anymore in the repo".

    Even though the model is small compared to the other GPT goliaths, it's still enough to pretty quickly use up your Git LFS storage allocation on GitHub. To work around this, we download the model from the Hugging Face library within the code itself.

## FastAPI

<div style="float: right; width: 50%">
    <img alt="FastAPI logo" src="../images/1-creating-rest-api/fastapi.png">
    <p style="font-weight: bold; margin-top: -10px; font-size: small; width: 100%; text-align: center">©️ Sebastián Ramírez</p>
</div>

Most (most not all) ML models use Python, so that's what we're going to use.

There are a bunch of different frameworks and libraries for creating APIs in Python - you might have used / heard of [Flask](https://flask.palletsprojects.com/en/2.2.x/) and [Django](https://www.djangoproject.com/) as the main ones. We are instead using a much newer and more modern framework called [FastAPI](https://fastapi.tiangolo.com/).

You should already be familiar with this from the introductory talk - to summarise, here are the main selling points of FastAPI:

- As the name suggests, it's super simple and quick to get set up and running - there's minimal boilerplate code and the documentation is excellent.
- It is based on modern language features like type hints, meaning excellent editor support (i.e. completion everywhere) and less code to write.
- It automatically creates and serves [interactive documentation](https://github.com/Redocly/redoc) and an [API specification](https://github.com/OAI/OpenAPI-Specification) for you.

We're really only scratching the surface of what you can do with FastAPI here.

## What's in our repo?

Let's have a quick look at the files we've got in our repository. Have an explore with the Codespaces editor. The important files are:

- `pyproject.toml` - This file specifies all of our dependencies
