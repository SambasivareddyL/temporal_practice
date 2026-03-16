import asyncio
import uuid
from temporalio.client import Client
from workflow import ApprovalWorkflow

async def main():
    client = await Client.connect("localhost:7233")
    workflow_id = f"approval-{uuid.uuid4().hex[:8]}"

    handle = await client.start_workflow(
        ApprovalWorkflow.run,
        "user@email.com",
        id=workflow_id,
        task_queue="approval-task-queue",
    )

    print("Workflow started:", handle.id)
    print("Approve:", f"http://localhost:8000/approve/{handle.id}")
    print("Reject:", f"http://localhost:8000/reject/{handle.id}")

asyncio.run(main())
