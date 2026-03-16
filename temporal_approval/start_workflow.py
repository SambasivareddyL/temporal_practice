import asyncio
from temporalio.client import Client
from workflow import ApprovalWorkflow

async def main():

    client = await Client.connect("localhost:7233")

    handle = await client.start_workflow(
        ApprovalWorkflow.run,
        "user@email.com",
        id="workflow123",
        task_queue="approval-task-queue",
    )

    print("Workflow started:", handle.id)

asyncio.run(main())
