from temporalio import activity

@activity.defn
async def send_email_activity(email: str, workflow_id: str):
    approval_link = f"http://localhost:8000/approve/{workflow_id}"
    reject_link = f"http://localhost:8000/reject/{workflow_id}"

    print(f"""
Email sent to {email}

Approve: {approval_link}
Reject: {reject_link}
""")

    # In real world you would send email via SendGrid / SES


@activity.defn
async def approved_activity():
    print("Approval received. Running approved activity.")
    return "Task Completed After Approval"
