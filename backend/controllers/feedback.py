"""
Feedback controller — allows users to send feedback with optional screenshots
via email to the development team using Gmail SMTP.
"""
import os
import uuid
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from controllers.auth import require_role
from controllers.email import GMAIL_USER, GMAIL_PASSWORD
from models.user import User

router = APIRouter(prefix="/feedback", tags=["Feedback"])

FEEDBACK_EMAIL = os.getenv("FEEDBACK_EMAIL", "kayting4k@gmail.com")
FEEDBACK_SUBJECT_PREFIX = "[PhotoSync Feedback]"


@router.post("/")
async def submit_feedback(
    message: str = Form(...),
    screenshot: UploadFile = File(None),
    current_user: User = Depends(require_role("admin", "teacher", "student")),
):
    """Submit feedback with optional screenshot attached as email."""
    if not GMAIL_USER or not GMAIL_PASSWORD:
        raise HTTPException(
            status_code=500,
            detail="Email service not configured. Please set GMAIL_USER and GMAIL_PASSWORD.",
        )

    if not message or not message.strip():
        raise HTTPException(status_code=400, detail="Feedback message is required")

    try:
        msg = MIMEMultipart("mixed")
        msg["From"] = GMAIL_USER
        msg["To"] = FEEDBACK_EMAIL
        msg["Subject"] = f"{FEEDBACK_SUBJECT_PREFIX} from {current_user.email} ({current_user.role})"

        # HTML body with user info and message
        html_body = f"""
        <!DOCTYPE html>
        <html>
          <head><meta charset="utf-8"></head>
          <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="text-align: center; margin-bottom: 24px;">
              <h1 style="color: #9D4EDD;">📬 PhotoSync Feedback</h1>
            </div>
            <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
              <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f9f9f9;"><strong>From</strong></td>
                  <td style="padding: 8px; border: 1px solid #ddd;">{current_user.email}</td></tr>
              <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f9f9f9;"><strong>Role</strong></td>
                  <td style="padding: 8px; border: 1px solid #ddd;">{current_user.role}</td></tr>
              <tr><td style="padding: 8px; border: 1px solid #ddd; background: #f9f9f9;"><strong>Screenshot</strong></td>
                  <td style="padding: 8px; border: 1px solid #ddd;">{'Attached ✓' if screenshot else 'No screenshot'}</td></tr>
            </table>
            <hr style="border: none; border-top: 2px solid #9D4EDD; margin: 24px 0;">
            <h3 style="color: #333;">Message:</h3>
            <div style="background: #f5f5f5; border-left: 4px solid #9D4EDD; padding: 16px; margin: 20px 0; border-radius: 4px;">
              <p style="margin: 0; color: #333; white-space: pre-wrap;">{message}</p>
            </div>
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;">
            <p style="color: #6b7280; font-size: 12px;">Sent automatically from PhotoSync app.</p>
          </body>
        </html>
        """

        msg.attach(MIMEText(html_body, "html"))

        # Attach screenshot if provided
        if screenshot and screenshot.filename:
            content = await screenshot.read()
            if len(content) > 0:
                attachment = MIMEBase("application", "octet-stream")
                attachment.set_payload(content)
                encoders.encode_base64(attachment)
                attachment.add_header(
                    "Content-Disposition",
                    f"attachment; filename=screenshot_{uuid.uuid4().hex[:8]}_{screenshot.filename}",
                )
                msg.attach(attachment)

        # Send via SMTP
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(GMAIL_USER, GMAIL_PASSWORD)
            server.send_message(msg)

        return {
            "success": True,
            "message": "Thank you! Your feedback has been sent successfully.",
        }

    except smtplib.SMTPAuthenticationError:
        raise HTTPException(
            status_code=500,
            detail="Gmail authentication failed. Contact the administrator.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to send feedback: {str(e)}",
        )