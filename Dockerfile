FROM python:3.10-slim

RUN \
    apt-get update --yes --quiet && \
    apt-get install --yes --quiet --no-install-recommends curl && \
    apt-get clean --yes --quiet

ENV \
    POETRY_VERSION="1.3.2" \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    VENV_PATH="/app/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN mkdir -p "$VENV_PATH"
WORKDIR "/app"

# Respects `POETRY_VERSION` and `POETRY_HOME` environment variables.
RUN curl -sSL https://install.python-poetry.org | python3 -

COPY ./pyproject.toml ./poetry.lock ./
RUN poetry install --no-dev --no-root

COPY README.md ./
COPY src ./src
RUN poetry install --no-dev


ENTRYPOINT ["gunicorn"]
CMD [ \
    "distilgpt2_api.api:app", \
    "--worker-class", "uvicorn.workers.UvicornWorker", \
    "--workers", "1", \
    "--bind", "0.0.0.0:8000" \
]
