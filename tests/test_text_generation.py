import pytest

from distilgpt2_api.text_generation import TextGenerator


@pytest.fixture
def text_generator():
    return TextGenerator()


def test_text_generator_generates_text(text_generator: TextGenerator):
    max_new_tokens = 25
    num_results = 5
    prompt = "Once upon a time there was a"

    output = text_generator.generate(
        prompt, max_new_tokens=max_new_tokens, num_return_sequences=num_results
    )

    assert isinstance(output, list) and all(isinstance(r, str) for r in output)
    assert len(output) == num_results

    # Results should include original text.
    assert all(r.startswith(prompt) and len(r) > len(prompt) for r in output)

    print("Prompt:", prompt)
    print("Responses:\n\t-", "\n\t- ".join(output))
