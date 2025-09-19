FROM ollama/ollama:latest

ENV OLLAMA_MODELS=/ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434
ENV PORT=11434

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 11434

ENTRYPOINT ["/bin/sh", "/start.sh"]
