FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install LibreTranslate
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir libretranslate==1.6.1

# Expose port for Render
EXPOSE 5000

# Set environment variables
ENV PORT=5000
ENV HOST=0.0.0.0
ENV LOAD_ONLY=en,ja

# Run LibreTranslate
CMD ["/usr/local/bin/python3", "-m", "libretranslate", "--host", "0.0.0.0", "--port", "5000", "--load-only", "en,ja"]