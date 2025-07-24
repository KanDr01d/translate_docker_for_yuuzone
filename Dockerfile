# Using Debian slim base image for stability
FROM debian:bookworm-slim

# Environment configuration
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    LT_HOST=0.0.0.0 \
    LT_PORT=5000

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-dev python3-pip python3-venv \
    git cmake pkg-config build-essential \
    gcc g++ make \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install Python dependencies (now simpler without spaCy/stanza)
RUN pip install --no-cache-dir \
    libretranslate==1.3.12 \
    sentencepiece \
    pybind11

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD curl -f http://0.0.0.0:5000/languages || exit 1

# Expose API port
EXPOSE 5000

# Run LibreTranslate - Only English/Japanese support
CMD ["libretranslate", \
    "--host", "0.0.0.0", \
    "--port", "5000", \
    "--load-only", "en,ja", \
    "--threads", "2", \
    "--metrics"]
