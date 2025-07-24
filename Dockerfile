FROM libretranslate/libretranslate:latest

# Switch to root user for installation
USER root

# Ensure package lists are clean (optional, but helps avoid apt issues)
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to default non-root user
USER libretranslate

# Expose port for Render
EXPOSE 5000

# Set environment variables
ENV PORT=5000
ENV HOST=0.0.0.0
ENV LOAD_ONLY=en,ja

# Start LibreTranslate
CMD ["python3", "-m", "libretranslate", "--host", "$HOST", "--port", "$PORT", "--load-only", "en,ja"]
