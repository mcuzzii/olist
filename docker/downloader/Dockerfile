FROM python:3.12-slim

# Prevent Python from creating .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install Kaggle CLI
RUN pip install --no-cache-dir kaggle requests pandas xlrd

WORKDIR /app

COPY download.py .