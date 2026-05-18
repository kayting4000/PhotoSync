"""
Email controller — sends grade report emails with scanned image attachments.
Uses Resend API for email delivery.
"""
import os
import httpx
import base64
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from typing import Optional
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from database import get_db
from controllers.auth import get_current_user
from models.user import User
from models.exam_result import ExamResult
from models.student import Student

load_dotenv()

RESEND_API_KEY = os.getenv("RESEND_API_KEY")
RESEND_FROM_EMAIL = os.getenv("RESEND_FROM_EMAIL", "PhotoSync <onboarding@resend.dev>")

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
    include_scan: bool = False


@router.post("/send-grade-report")
async def send_grade_report(
    body: GradeReportEmailRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send a grade report email to a student, optionally with scanned image attached."""
    if not RESEND_API_KEY:
        return {
            "success": True,
            "message": "Email simulated (RESEND_API_KEY not configured)",
        }

    # Get student info
    student = db.query(Student).filter(
        Student.id == body.student_id,
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

    # Prepare attachments
    attachments = []
    if body.include_scan:
        # Find the latest exam result for this student
        result = db.query(ExamResult).filter(
            ExamResult.user_id == current_user.id,
            ExamResult.student_id == body.student_id,
        ).order_by(ExamResult.created_at.desc()).first()

        if result and result.scanned_image_url:
            # The URL is like "/uploads/filename.jpg"
            # Convert to filesystem path
            file_path = os.path.join(
                os.path.dirname(os.path.dirname(__file__)),
                result.scanned_image_url.lstrip("/"),
            )
            if os.path.exists(file_path):
                with open(file_path, "rb") as f:
                    img_data = f.read()
                img_b64 = base64.b64encode(img_data).decode()
                attachments.append({
                    "filename": f"scanned_test_{body.student_id[:8]}.jpg",
                    "content": img_b64,
                })

    # Send via Resend
    async with httpx.AsyncClient(timeout=30.0) as client:
        payload = {
            "from": RESEND_FROM_EMAIL,
            "to": [student.email],
            "subject": f"Grade Report - {body.subject_code} {body.subject_name}",
            "html": html,
        }
        if attachments:
            payload["attachments"] = attachments

        res = await client.post(
            "https://api.resend.com/emails",
            headers={
                "Authorization": f"Bearer {RESEND_API_KEY}",
                "Content-Type": "application/json",
            },
            json=payload,
        )

    if res.status_code != 200:
        raise HTTPException(status_code=500, detail=f"Email send failed: {res.text}")

    return {
        "success": True,
        "message": f"Grade report sent to {student.email}",
        "has_attachment": len(attachments) > 0,
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