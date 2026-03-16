import asyncio
from temporalio.client import Client
from temporalio.worker import Worker

from workflow import ApprovalWorkflow
from activities import send_email_activity, approved_activity

async def main():

    client = await Client.connect("localhost:7233")

    worker = Worker(
        client,
        task_queue="approval-task-queue",
        workflows=[ApprovalWorkflow],
        activities=[send_email_activity, approved_activity],
    )

    await worker.run()

asyncio.run(main())
