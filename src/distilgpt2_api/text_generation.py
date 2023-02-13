from os import PathLike
from pathlib import Path
from typing import TypedDict, cast

from transformers import (
    GPT2LMHeadModel,
    GPT2Tokenizer,
    TextGenerationPipeline,
    pipeline,
    set_seed,
)


class GeneratedText(TypedDict):
    generated_text: str


class TextGenerator:
    generator: TextGenerationPipeline

    def __init__(
        self, seed: int = 42, model_path: str | PathLike | None = None
    ) -> None:
        model = GPT2LMHeadModel.from_pretrained(
            model_path if model_path is not None else "distilgpt2"
        )
        tokeniser = GPT2Tokenizer.from_pretrained(
            model_path if model_path is not None else "distilgpt2"
        )
        self.generator = cast(
            TextGenerationPipeline,
            pipeline("text-generation", model=model, tokenizer=tokeniser),
        )
        set_seed(seed)

    def generate(
        self, prompt: str, max_new_tokens: int = 50, num_return_sequences: int = 1
    ) -> list[str]:
        results = cast(
            list[GeneratedText],
            self.generator(
                prompt,
                max_new_tokens=max_new_tokens,
                num_return_sequences=num_return_sequences,
            ),
        )
        return [r["generated_text"] for r in results]
