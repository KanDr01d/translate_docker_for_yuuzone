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

# Install Python dependencies
RUN pip install --no-cache-dir \
    libretranslate==1.3.12 \
    sentencepiece \
    pybind11 \
    spacy==3.5.0 \
    stanza

# Download spaCy models for English and Vietnamese
RUN python -m spacy download en_core_web_sm && \
    python -m spacy download vi_core_news_lg

# Check installed packages
RUN pip list

# Configure LibreTranslate to use spaCy for Vietnamese
RUN mkdir -p /app/models && \
    echo "VIETNAMESE_SBD_MODEL=spacy" > /app/models/vietnamese.cfg

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD curl -f http://0.0.0.0:5000/languages || exit 1

# Expose API port
EXPOSE 5000

# Run LibreTranslate with spaCy integration
CMD ["libretranslate", \
    "--host", "0.0.0.0", \  # Binding to all interfaces
    "--port", "5000", \
    "--load-only", "en,ja,vi", \
    "--threads", "2", \
    "--metrics"]
