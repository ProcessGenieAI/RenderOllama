#!/bin/sh
set -eu

OLLAMA_MODELS=${OLLAMA_MODELS:-/ollama/models}
OLLAMA_HOST=${OLLAMA_HOST:-0.0.0.0:11434}
API_URL="http://127.0.0.1:11434"

mkdir -p "$OLLAMA_MODELS"
export OLLAMA_MODELS OLLAMA_HOST

echo "Starting ollama serve..."
ollama serve &          # background the server so we can pull models
child_pid=$!

# ensure we kill child when container is stopped
cleanup() {
  echo "Caught signal: stopping ollama (pid $child_pid)..."
  kill "$child_pid" 2>/dev/null || true
  wait "$child_pid" 2>/dev/null || true
  exit 0
}
trap cleanup INT TERM

# wait for API to be responsive (timeout after 120s)
echo "Waiting for Ollama API to be available..."
count=0
until curl --silent --fail "${API_URL}/api/tags" >/dev/null 2>&1; do
  count=$((count+1))
  if [ "$count" -gt 120 ]; then
    echo "ERROR: timeout waiting for Ollama API (after 120s)"
    # ensure child stays cleaned up so container exits with an informative state
    cleanup
  fi
  sleep 1
done
echo "Ollama API is up."

# Pull only what we need (adjust model names as desired)
if ! ollama list | grep -q "gemma:2b"; then
  echo "Pulling gemma:2b..."
  ollama pull gemma:2b || { echo "ERROR: ollama pull gemma:2b failed"; cleanup; }
fi

if ! ollama list | grep -q "nomic-embed-text"; then
  echo "Pulling nomic-embed-text..."
  ollama pull nomic-embed-text || { echo "ERROR: ollama pull nomic-embed-text failed"; cleanup; }
fi

echo "Models pulled. Now handing control to ollama serve (pid $child_pid)."
# Wait on the server process so container stays alive while it's running
wait "$child_pid"
