#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_DIR"

# Create venv if missing
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

# Activate venv
source .venv/bin/activate

# Install requirements
pip install --upgrade pip
pip install -r requirements.txt

# Start Temporal dev server in background
if ! pgrep -f "temporal server" >/dev/null 2>&1; then
  echo "Starting Temporal dev server..."
  temporal server start-dev >/tmp/temporal-server.log 2>&1 &
  sleep 5
else
  echo "Temporal server already running."
fi

# Start worker
if ! pgrep -f "python temporal_approval/worker.py" >/dev/null 2>&1; then
  echo "Starting Temporal worker..."
  python temporal_approval/worker.py >/tmp/temporal-worker.log 2>&1 &
  sleep 2
else
  echo "Worker already running."
fi

# Start FastAPI server
if ! pgrep -f "uvicorn temporal_approval.api" >/dev/null 2>&1; then
  echo "Starting API server..."
  uvicorn temporal_approval.api:app --reload --port 8000 >/tmp/temporal-api.log 2>&1 &
  sleep 2
else
  echo "API server already running."
fi

# Start workflow runner
echo "Starting workflow..."
python temporal_approval/start_workflow.py

echo "Done. API at http://localhost:8000"