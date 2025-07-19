#!/bin/bash

echo "Starting PostgreSQL..."
service postgresql start

echo "Starting Ollama..."
nohup ollama serve > /workspace/ollama.log 2>&1 &

echo "Starting Flowise..."
nohup flowise start > /workspace/flowise.log 2>&1 &

echo "Starting code-server..."
nohup code-server --user-data-dir /workspace/.config/code-server --bind-addr 0.0.0.0:8080 > /workspace/code-server.log 2>&1 &

# Optional: Chroma server (local, in-process DB)
echo "Starting Chroma (if needed)..."
nohup python3 -m chromadb.cli.cli --host 0.0.0.0 --port 8000 --path /workspace/chroma > /workspace/chroma.log 2>&1 &

# Keep container running
tail -f /dev/null
