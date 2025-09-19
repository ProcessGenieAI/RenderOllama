#!/bin/sh
set -e

# env defaults
OLLAMA_MODELS=${OLLAMA_MODELS:-/ollama/models}
OLLAMA_HOST=${OLLAMA_HOST:-0.0.0.0:11434}
API_URL="http://127.0.0.1:11434"

mkdir -p "$OLLAMA_MODELS"
export OLLAMA_MODELS
export OLLAMA_HOST

# Start ollama server in background
ollama serve &

# wait for the server to become healthy
echo "Waiting for Ollama API to become available..."
until curl --silent --fail "${API_URL}/api/tags" >/dev/null 2>&1; do
  sleep 1
done
echo "Ollama API is up."

# Pull needed model(s) if not present.
# Replace gemma:2b / nomic-embed-text with the model(s) you want.
if ! ollama list | grep -q "gemma:2b"; then
  echo "Pulling gemma:2b (this can take a while)..."
  ollama pull gemma:2b
fi
if ! ollama list | grep -q "nomic-embed-text"; then
  echo "Pulling nomic-embed-text (for embeddings)..."
  ollama pull nomic-embed-text
fi

# (Optional) verify tags
ollama list
echo "Startup complete — keeping Ollama process in foreground."

# Wait on foreground process (ollama serve was backgrounded; run tail to keep container alive)
wait -n
