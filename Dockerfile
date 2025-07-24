# Using Debian slim base image for stability
FROM debian:bookworm-slim

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LT_LOAD_ONLY=en,ja,vi \
    LT_THREADS=4 \
    LT_HOST=0.0.0.0 \
    LT_PORT=5000 \
    # Optimize for our three target languages
    ARGOS_MODELS="opus-mt-en-ja opus-mt-ja-en opus-mt-en-vi opus-mt-vi-en" \
    UPDATE_INTERVAL=86400

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git \
    cmake \
    pkg-config \
    build-essential \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install LibreTranslate with pinned version
RUN pip install --no-cache-dir libretranslate==1.3.12

# Install required language models
RUN libretranslate --update-models --load-only en,ja,vi

# Create runtime directory
RUN mkdir -p /app/models && chmod 777 /app /app/models

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://0.0.0.0:5000/languages || exit 1

# Expose API port
EXPOSE 5000

# Runtime configuration
CMD ["libretranslate", \
     "--host", "0.0.0.0", \
     "--port", "5000", \
     "--load-only", "en,ja,vi", \
     "--update-models", \
     "--threads", "4", \
     "--metrics"]
