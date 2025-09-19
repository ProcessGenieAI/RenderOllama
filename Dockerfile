FROM ghcr.io/ollama/ollama:latest

# Choose where to mount model storage (match the Render disk mount)
ENV OLLAMA_MODELS=/ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434
ENV PORT=11434

# copy a start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 11434
CMD ["/start.sh"]
