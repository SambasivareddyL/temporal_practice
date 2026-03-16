from temporalio import activity
import requests

@activity.defn
async def send_email_activity(email: str):

    approval_link = "http://localhost:8000/approve/workflow123"
    reject_link = "http://localhost:8000/reject/workflow123"

    print(f"""
    Email sent to {email}

    Approve:
    {approval_link}

    Reject:
    {reject_link}
    """)

    # In real world you would send email via SendGrid / SES


@activity.defn
async def approved_activity():
    print("Approval received. Running approved activity.")
    return "Task Completed After Approval"
