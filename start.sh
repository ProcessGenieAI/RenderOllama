#!/bin/sh
set -e

# ensure model dir exists
mkdir -p "$OLLAMA_MODELS"

# example: pull a model if not present (adjust model name you want)
if [ ! -d "$OLLAMA_MODELS/gemma" ]; then
  echo "Pulling gemma model..."
  ollama pull gemma:2b || true
fi

# Ensure server binds publicly (Ollama reads OLLAMA_HOST)
export OLLAMA_HOST=${OLLAMA_HOST:-0.0.0.0:11434}
exec ollama serve
