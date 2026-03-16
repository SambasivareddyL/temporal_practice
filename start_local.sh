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
fi

# Wait for Temporal server to be ready
for i in {1..30}; do
  if nc -z localhost 7233 >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for Temporal server on 7233... ($i)"
  sleep 1
done
if ! nc -z localhost 7233 >/dev/null 2>&1; then
  echo "Temporal server failed to start. Check /tmp/temporal-server.log"
  exit 1
fi

tmp_worker_log="/tmp/temporal-worker.log"
if ! pgrep -f "python temporal_approval/worker.py" >/dev/null 2>&1; then
  echo "Starting Temporal worker..."
  python temporal_approval/worker.py >"$tmp_worker_log" 2>&1 &
  sleep 2
fi

# Start FastAPI server
if ! pgrep -f "uvicorn temporal_approval.api" >/dev/null 2>&1; then
  echo "Starting API server..."
  uvicorn temporal_approval.api:app --reload --port 8000 >/tmp/temporal-api.log 2>&1 &
fi

for i in {1..30}; do
  if nc -z localhost 8000 >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for API server on 8000... ($i)"
  sleep 1
done
if ! nc -z localhost 8000 >/dev/null 2>&1; then
  echo "API server failed to start. Check /tmp/temporal-api.log"
  exit 1
fi

# Start workflow runner
echo "Starting workflow..."
python temporal_approval/start_workflow.py

echo
cat <<'INFO'
=== Service URLs ===
Temporal UI: http://localhost:8088
API docs: http://localhost:8000/docs
API health: http://localhost:8000

=== Workflow links ===
(Workflow ID printed by start_workflow.py)
Approve: http://localhost:8000/approve/<workflow_id>
Reject: http://localhost:8000/reject/<workflow_id>

=== Log files ===
Temporal: /tmp/temporal-server.log
Worker: /tmp/temporal-worker.log
API: /tmp/temporal-api.log
INFO