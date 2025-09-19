FROM ollama/ollama:latest

# use an explicit dir for models in the container's filesystem (ephemeral on Free)
ENV OLLAMA_MODELS=/ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434
ENV PORT=11434

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 11434
CMD ["/start.sh"]
