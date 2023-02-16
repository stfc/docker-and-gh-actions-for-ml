FROM python:3.10-slim

ENV \
    POETRY_VERSION="1.3.2" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    VENV_PATH="/app/.venv"

ENV PATH="$VENV_PATH/bin:/root/.local/bin:$PATH"
RUN mkdir -p "$VENV_PATH"
WORKDIR "/app"

RUN pip install pipx && pipx install poetry==$POETRY_VERSION

COPY ./pyproject.toml ./poetry.lock ./
RUN poetry install --no-dev --no-root

COPY README.md ./
COPY src ./src
RUN poetry install --no-dev

EXPOSE 8000

CMD [ \
    "gunicorn", \
    "distilgpt2_api.api:app", \
    "--worker-class", "uvicorn.workers.UvicornWorker", \
    "--workers", "1", \
    "--bind", "0.0.0.0:8000" \
]