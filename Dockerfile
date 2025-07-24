FROM debian:bookworm-slim

# Core environment variables (MUST match .env file)
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    LT_HOST=0.0.0.0 \
    LT_PORT=5000 \
    LT_LOAD_ONLY=en,ja \
    LT_THREADS=2 \
    PROMETHEUS_MULTIPROC_DIR=/db/prometheus

# Create all required directories upfront
RUN mkdir -p /db/prometheus && \
    chmod 777 /db /db/prometheus && \
    mkdir -p /app/models

# System setup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-dev python3-pip python3-venv \
    git cmake pkg-config build-essential \
    gcc g++ make && \
    rm -rf /var/lib/apt/lists/*

# Python environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install only necessary dependencies
RUN pip install --no-cache-dir \
    libretranslate==1.3.12 \
    sentencepiece \
    pybind11

EXPOSE 5000

CMD ["libretranslate", \
    "--host", "$LT_HOST", \
    "--port", "$LT_PORT", \
    "--load-only", "$LT_LOAD_ONLY", \
    "--threads", "$LT_THREADS", \
    "--metrics"]
