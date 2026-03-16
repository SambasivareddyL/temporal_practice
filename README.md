# temporal_practice

Runnables for a Temporal approval workflow demo.

## Setup

1. Install Python dependencies:
```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```
2. Start Temporal dev server (in another terminal):
```bash
temporal server start-dev
```

## Run

1. Start worker:
```bash
python temporal_approval/worker.py
```
2. Start API server:
```bash
uvicorn temporal_approval.api:app --reload --port 8000
```
3. Start workflow:
```bash
python temporal_approval/start_workflow.py
```
4. Use printed /approve/{workflow_id} or /reject/{workflow_id} links in browser or curl.

## Files
- `temporal_approval/worker.py`: runs Temporal worker
- `temporal_approval/workflow.py`: approval workflow logic
- `temporal_approval/activities.py`: side-effect activities
- `temporal_approval/api.py`: simple FastAPI signal endpoints
- `temporal_approval/start_workflow.py`: starts a workflow and prints links
