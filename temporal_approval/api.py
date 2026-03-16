from fastapi import FastAPI
from temporalio.client import Client

app = FastAPI()

@app.get("/approve/{workflow_id}")
async def approve(workflow_id: str):
    client = await Client.connect("localhost:7233")
    handle = client.get_workflow_handle(workflow_id)
    await handle.signal("approve")
    return {"status": "Approved", "workflow_id": workflow_id}

@app.get("/reject/{workflow_id}")
async def reject(workflow_id: str):
    client = await Client.connect("localhost:7233")
    handle = client.get_workflow_handle(workflow_id)
    await handle.signal("reject")
    return {"status": "Rejected", "workflow_id": workflow_id}
