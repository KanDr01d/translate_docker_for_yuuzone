# Use the official Python image as a base
FROM python:3.9-slim

# Set environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Focus on English, Japanese, Vietnamese
ENV LT_LOAD_ONLY=en,ja,vi
ENV LT_THREADS=4
ENV LT_HOST=0.0.0.0
ENV LT_PORT=5000

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /app

# Install LibreTranslate
RUN pip install --no-cache-dir libretranslate

# Download language models (English, Japanese, Vietnamese)
RUN libretranslate --load-only en,ja,vi --download-models

# Expose the API port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/languages || exit 1

# Run LibreTranslate
CMD ["libretranslate", "--host", "0.0.0.0", "--port", "5000", "--load-only", "en,ja,vi"]
