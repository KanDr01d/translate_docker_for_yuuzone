FROM libretranslate/libretranslate:latest

# Install dependencies for Japanese and Vietnamese
RUN apt-get update && apt-get install -y \
    python3-pip \
    && pip3 install argos-translate \
    && argospm install translate-ja_en \
    && argospm install translate-en_ja \
    && argospm install translate-vi_en \
    && argospm install translate-en_vi \
    && rm -rf /var/lib/apt/lists/*

# Expose port for Render
EXPOSE 5000

# Set environment variables
ENV LT_PORT=5000
ENV LT_HOST=0.0.0.0

# Start LibreTranslate
CMD ["python3", "-m", "libretranslate", "--host", "$LT_HOST", "--port", "$LT_PORT"]
