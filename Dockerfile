FROM ollama/ollama:latest

ENV OLLAMA_MODELS=/ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434
ENV PORT=11434
RUN ollama pull gemma:2b

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 11434

# Run the script with /bin/sh as PID 1 so it *executes*, not passed as args to ollama
ENTRYPOINT ["/bin/sh", "/start.sh"]
