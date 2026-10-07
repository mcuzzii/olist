FROM python:3.12-slim

# Install uv from Astral's official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Create the project's virtual environment
RUN uv venv /app/.venv

# Install ingestion dependencies into the virtual environment
RUN uv pip install --python /app/.venv/bin/python \
    kaggle \
    edne-correios-loader \
    "psycopg[binary]" \
    pandas \
    xlrd \
    requests

COPY . /app/docker/data-loader