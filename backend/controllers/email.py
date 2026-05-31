"""
Email controller — sends grade report emails and transcripts.
Uses Gmail SMTP for email delivery.
"""
import os
import smtplib
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from typing import Optional
from sqlalchemy.orm import Session, joinedload
from dotenv import load_dotenv

from database import get_db
from controllers.auth import get_current_user
from models.user import User
from models.student import Student
from models.exam_result import ExamResult
from models.exam import Exam
from models.subject import Subject
from email_templates import grade_report_template, transcript_template

load_dotenv()

# Gmail SMTP Configuration
GMAIL_USER = os.getenv("GMAIL_USER")
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD")
GMAIL_SMTP_SERVER = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587  # TLS port (or 465 for SSL)

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


def _send_email_via_gmail(to_email: str, subject: str, html_content: str) -> bool:
    """
    Send email via Gmail SMTP.
    
    Args:
        to_email: Recipient email address
        subject: Email subject
        html_content: HTML email body
        
    Returns:
        True if successful, raises HTTPException otherwise
    """
    if not GMAIL_USER or not GMAIL_PASSWORD:
        raise HTTPException(
            status_code=503,
            detail="Gmail SMTP not configured. Set GMAIL_USER and GMAIL_PASSWORD environment variables."
        )
    
    try:
        # Create message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = GMAIL_USER
        msg['To'] = to_email
        
        # Attach HTML content
        msg.attach(MIMEText(html_content, 'html'))
        
        # Send via Gmail SMTP with TLS
        with smtplib.SMTP(GMAIL_SMTP_SERVER, GMAIL_SMTP_PORT) as server:
            server.starttls()  # Upgrade connection to TLS
            server.login(GMAIL_USER, GMAIL_PASSWORD)
            server.send_message(msg)
        
        return True
        
    except smtplib.SMTPAuthenticationError:
        raise HTTPException(
            status_code=401,
            detail="Gmail authentication failed. Check GMAIL_USER and GMAIL_PASSWORD."
        )
    except smtplib.SMTPException as e:
        raise HTTPException(
            status_code=502,
            detail=f"Gmail SMTP error: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to send email: {str(e)}"
        )


@router.post("/send-grade-report")
async def send_grade_report(
    body: GradeReportEmailRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send a grade report email to a student."""
    
    # Get student info
    student = db.query(Student).filter(
        Student.id == body.student_id,
        Student.user_id == current_user.id,
    ).first()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    if not student.email:
        raise HTTPException(status_code=400, detail="Student has no email address")
    
    # Build email HTML using enhanced template
    html = grade_report_template(
        student_name=f"{student.first_name} {student.last_name}",
        exam_name=body.exam_name,
        subject_code=body.subject_code,
        subject_name=body.subject_name,
        percentage=body.percentage,
        grade=body.grade,
        grade_point=body.grade_point,
        remarks=body.remarks,
        custom_message=body.custom_message
    )
    
    # Send email
    _send_email_via_gmail(
        to_email=student.email,
        subject=f"Grade Report - {body.subject_code} {body.subject_name}",
        html_content=html
    )
    
    return {
        "success": True,
        "message": f"Grade report sent to {student.email}",
    }


@router.post("/send-grade-transcript")
async def send_grade_transcript(
    student_id: str,
    custom_message: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Send complete grade transcript to student."""
    
    # Get student
    student = db.query(Student).filter(
        Student.id == student_id,
        Student.user_id == current_user.id,
    ).first()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    if not student.email:
        raise HTTPException(status_code=400, detail="Student has no email address")
    
    # Get all grades
    results = db.query(ExamResult).options(
        joinedload(ExamResult.exam).joinedload(Exam.subject)
    ).filter(
        ExamResult.student_id == student_id,
        ExamResult.user_id == current_user.id,
    ).all()
    
    # Build transcript
    subjects_dict = {}
    for result in results:
        if not result.exam or not result.exam.subject:
            continue
        subject = result.exam.subject
        subject_id = str(subject.id)
        if subject_id not in subjects_dict:
            subjects_dict[subject_id] = {
                "code": subject.code,
                "name": subject.name,
                "units": subject.units,
                "grades": [],
            }
        subjects_dict[subject_id]["grades"].append(result.percentage or 0)
    
    # Calculate GPA
    weighted_sum = 0.0
    total_units = 0
    transcript_rows = ""
    
    for subject_id, subject_data in subjects_dict.items():
        avg_grade = sum(subject_data["grades"]) / len(subject_data["grades"])
        units = subject_data["units"]
        weighted_sum += avg_grade * units
        total_units += units
        
        transcript_rows += f"""
    <tr>
      <td>{subject_data['code']}</td>
      <td>{subject_data['name']}</td>
      <td style="text-align: center;">{units}</td>
      <td style="text-align: center;">{avg_grade:.2f}%</td>
    </tr>
        """
    
    gpa = round(weighted_sum / total_units, 4) if total_units > 0 else 0
    
    # Build email HTML using enhanced template
    html = transcript_template(
        student_name=f"{student.first_name} {student.last_name}",
        student_id=student.student_id,
        course=student.course,
        year_level=student.year_level,
        transcript_rows=transcript_rows,
        gpa=gpa,
        custom_message=custom_message
    )
    
    # Send email
    _send_email_via_gmail(
        to_email=student.email,
        subject=f"Official Grade Transcript - {student.first_name} {student.last_name}",
        html_content=html
    )
    
    return {
        "success": True,
        "message": f"Grade transcript sent to {student.email}",
        "gpa": gpa,
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
