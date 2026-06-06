"""
Email controller — sends grade report emails (results only, no attachments).
Uses Gmail SMTP for email delivery.
"""
import os
import uuid
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from database import get_db
from controllers.auth import get_current_user
from models.user import User
from models.student import Student

load_dotenv()

GMAIL_USER = os.getenv("GMAIL_USER")
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD")

router = APIRouter(prefix="/email", tags=["Email"])


class GradeReportEmailRequest(BaseModel):
    student_id: str
    exam_name: str
    subject_code: str
    subject_name: str
    percentage: float
    grade: str
    grade_point: float
    remarks: str
    custom_message: Optional[str] = None


def send_email_smtp(to_email: str, subject: str, html_content: str):
    """Send an email using Gmail SMTP."""
    if not GMAIL_USER or not GMAIL_PASSWORD:
        raise HTTPException(
            status_code=500,
            detail="Email service not configured. Please set GMAIL_USER and GMAIL_PASSWORD environment variables.",
        )

    msg = MIMEMultipart("alternative")
    msg["From"] = GMAIL_USER
    msg["To"] = to_email
    msg["Subject"] = subject

    msg.attach(MIMEText(html_content, "html"))

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(GMAIL_USER, GMAIL_PASSWORD)
            server.send_message(msg)
    except smtplib.SMTPAuthenticationError:
        raise HTTPException(
            status_code=500,
            detail="Gmail authentication failed. Check your GMAIL_USER and GMAIL_PASSWORD.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Email send failed: {str(e)}",
        )


@router.post("/send-grade-report")
async def send_grade_report(
    body: GradeReportEmailRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send a grade report email to a student (results only, no attachments)."""
    # Get student info (convert string IDs to UUID for PostgreSQL compatibility)
    try:
        student_uuid = uuid.UUID(body.student_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid student ID format")

    student = db.query(Student).filter(
        Student.id == student_uuid,
        Student.user_id == current_user.id,
    ).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    if not student.email:
        raise HTTPException(status_code=400, detail="Student has no email address")

    # Build email HTML
    html = f"""
    <!DOCTYPE html>
    <html>
      <head><meta charset="utf-8"></head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 24px;">
          <h1 style="color: #2563eb;">PhotoSync</h1>
          <p style="color: #6b7280;">Grade Report</p>
        </div>
        <p>Dear <strong>{student.first_name} {student.last_name}</strong>,</p>
        <p>Here is your grade report for <strong>{body.subject_code} - {body.subject_name}</strong>:</p>
        <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
          <tr><td style="padding: 8px; border: 1px solid #ddd;"><strong>Exam</strong></td>
              <td style="padding: 8px; border: 1px solid #ddd;">{body.exam_name}</td></tr>
          <tr><td style="padding: 8px; border: 1px solid #ddd;"><strong>Percentage</strong></td>
              <td style="padding: 8px; border: 1px solid #ddd;">{body.percentage:.1f}%</td></tr>
          <tr><td style="padding: 8px; border: 1px solid #ddd;"><strong>Grade</strong></td>
              <td style="padding: 8px; border: 1px solid #ddd;">{body.grade} ({body.grade_point:.2f})</td></tr>
          <tr><td style="padding: 8px; border: 1px solid #ddd;"><strong>Status</strong></td>
              <td style="padding: 8px; border: 1px solid #ddd; color: {'#16a34a' if body.remarks == 'Passed' else '#dc2626'}; font-weight: bold;">{body.remarks}</td></tr>
        </table>
        {f'<div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 16px; margin: 20px 0;"><p><strong>Message:</strong></p><p>{body.custom_message}</p></div>' if body.custom_message else ''}
        <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;">
        <p style="color: #6b7280; font-size: 12px;">This is an automated message from PhotoSync.</p>
      </body>
    </html>
    """

    send_email_smtp(
        to_email=student.email,
        subject=f"Grade Report - {body.subject_code} {body.subject_name}",
        html_content=html,
    )

    return {
        "success": True,
        "message": f"Grade report sent to {student.email}",
    }


@router.post("/send-bulk-reports")
async def send_bulk_reports(
    body: list[GradeReportEmailRequest],
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send grade report emails to multiple students at once."""
    results = []
    for req in body:
        try:
            result = await send_grade_report(req, db, current_user)
            results.append({
                "student_id": req.student_id,
                "success": True,
                "message": result["message"],
            })
        except HTTPException as e:
            results.append({
                "student_id": req.student_id,
                "success": False,
                "message": e.detail,
            })
        except Exception as e:
            results.append({
                "student_id": req.student_id,
                "success": False,
                "message": str(e),
            })

    return {"results": results}