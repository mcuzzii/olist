FROM python:3.12-slim

# Install uv from Astral's official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

CMD ["sleep", "infinity"]