import json
import os
import boto3

FROM_ADDRESS = os.environ["FROM_ADDRESS"]
TO_ADDRESS = os.environ["TO_ADDRESS"]
ses = boto3.client("sesv2")


def _response(status, payload):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }


def handler(event, context):
    try:
        data = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "Body must be JSON"})

    name = str(data.get("name", "")).strip()
    email = str(data.get("email", "")).strip()
    message = str(data.get("message", "")).strip()

    if not name or not email or not message:
        return _response(400, {"error": "name, email and message are required"})
    if len(name) > 100 or len(email) > 254 or len(message) > 2000 or "@" not in email:
        return _response(400, {"error": "Invalid input"})

    ses.send_email(
        FromEmailAddress=FROM_ADDRESS,
        Destination={"ToAddresses": [TO_ADDRESS]},
        ReplyToAddresses=[email],
        Content={
            "Simple": {
                "Subject": {"Data": f"Portfolio contact from {name}"},
                "Body": {"Text": {"Data": f"Name: {name}\nEmail: {email}\n\n{message}"}},
            }
        },
    )

    return _response(200, {"ok": True})