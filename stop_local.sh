#!/usr/bin/env bash
set -euo pipefail

echo "Stopping local Temporal environment..."

pkill -f "temporal server start-dev" 2>/dev/null || true
pkill -f "python temporal_approval/worker.py" 2>/dev/null || true
pkill -f "uvicorn temporal_approval.api" 2>/dev/null || true

echo "Stopped."

echo "Remaining processes:"
pgrep -af "temporal server start-dev|python temporal_approval/worker.py|uvicorn temporal_approval.api" || echo "None"