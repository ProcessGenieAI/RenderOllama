#!/bin/sh
set -eu

OLLAMA_MODELS=${OLLAMA_MODELS:-/ollama/models}
OLLAMA_HOST=${OLLAMA_HOST:-0.0.0.0:11434}
API_URL="http://127.0.0.1:11434"

mkdir -p "$OLLAMA_MODELS"
export OLLAMA_MODELS OLLAMA_HOST
startTimeout: 500  # increase to 5 minutes (seconds)

echo "Starting ollama serve..."
ollama serve &          # Start the server in the background
child_pid=$!

cleanup() {
  echo "Caught signal: stopping ollama (pid $child_pid)..."
  kill "$child_pid" 2>/dev/null || true
  wait "$child_pid" 2>/dev/null || true
  exit 0
}
trap cleanup INT TERM

echo "Waiting for Ollama API to be available..."
count=0
until curl --silent --fail "${API_URL}/api/tags" >/dev/null 2>&1; do
  count=$((count+1))
  if [ "$count" -gt 120 ]; then
    echo "ERROR: timeout waiting for Ollama API (after 120s)"
    cleanup
  fi
  sleep 1
done
echo "Ollama API is up."

# Pull the required models
for model in "gemma:2b" "nomic-embed-text"; do
  if ! ollama list | grep -q "$model"; then
    echo "Pulling $model..."
    ollama pull "$model" || { echo "ERROR: ollama pull $model failed"; cleanup; }
  fi
done

echo "Models pulled. Now handing control to ollama serve (pid $child_pid)."
wait "$child_pid"
