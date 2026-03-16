from temporalio import workflow
from temporalio.common import RetryPolicy
from datetime import timedelta

@workflow.defn
class ApprovalWorkflow:

    def __init__(self):
        self.approved = None

    @workflow.signal
    def approve(self):
        self.approved = True

    @workflow.signal
    def reject(self):
        self.approved = False

    @workflow.run
    async def run(self, email: str):

        # Step 1: send approval email
        await workflow.execute_activity(
            "send_email_activity",
            email,
            workflow.info.workflow_id,
            start_to_close_timeout=timedelta(seconds=30),
            retry_policy=RetryPolicy(maximum_attempts=3),
        )

        # Step 2: wait until approval/rejection
        await workflow.wait_condition(lambda: self.approved is not None)

        # Step 3: branch logic
        if self.approved:
            result = await workflow.execute_activity(
                "approved_activity",
                start_to_close_timeout=timedelta(seconds=30),
            )
            return result

        else:
            return "Rejected"
