import logging
from functools import cache

from fastapi import FastAPI

from .text_generation import TextGenerator

app = FastAPI()


@cache
def get_model() -> TextGenerator:
    logging.info("Loading DistilGPT2 model")
    return TextGenerator()


@app.on_event("startup")
async def on_startup():
    get_model()


@app.get("/")
async def health():
    return {"health": "ok"}


@app.get("/{prompt}")
async def generate_text(
    prompt: str,
    max_new_tokens: int = 50,
    num_return_sequences: int = 1,
) -> dict:
    model = get_model()
    sequences = model.generate(
        prompt, max_new_tokens=max_new_tokens, num_return_sequences=num_return_sequences
    )
    return {"generated_sequences": sequences}