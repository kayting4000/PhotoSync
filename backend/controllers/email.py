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
    
    # Build email HTML
    html = f"""
    <!DOCTYPE html>
    <html>
      <head><meta charset="utf-8"></head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 24px;">
          <h1 style="color: #2563eb;">EduScan</h1>
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
        <p style="color: #6b7280; font-size: 12px;">This is an automated message from EduScan.</p>
      </body>
    </html>
    """
    
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
          <td style="padding: 10px; border: 1px solid #ddd;">{subject_data['code']}</td>
          <td style="padding: 10px; border: 1px solid #ddd;">{subject_data['name']}</td>
          <td style="padding: 10px; border: 1px solid #ddd; text-align: center;">{units}</td>
          <td style="padding: 10px; border: 1px solid #ddd; text-align: center;">{avg_grade:.2f}%</td>
        </tr>
        """
    
    gpa = round(weighted_sum / total_units, 4) if total_units > 0 else 0
    
    html = f"""
    <!DOCTYPE html>
    <html>
      <head><meta charset="utf-8"></head>
      <body style="font-family: Arial, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2563eb; margin: 0;">EduScan</h1>
          <p style="color: #6b7280; margin: 5px 0 0 0;">Official Grade Transcript</p>
        </div>
        
        <div style="background: #f9fafb; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
          <p><strong>Student Name:</strong> {student.first_name} {student.last_name}</p>
          <p><strong>Student ID:</strong> {student.student_id}</p>
          <p><strong>Course:</strong> {student.course}</p>
          <p><strong>Year Level:</strong> {student.year_level}</p>
        </div>
        
        <h3 style="color: #1f2937; margin-top: 20px;">Academic Record</h3>
        <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
          <thead>
            <tr style="background: #e5e7eb;">
              <th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Subject Code</th>
              <th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Subject Name</th>
              <th style="padding: 10px; border: 1px solid #ddd; text-align: center;">Units</th>
              <th style="padding: 10px; border: 1px solid #ddd; text-align: center;">Average Grade</th>
            </tr>
          </thead>
          <tbody>
            {transcript_rows}
          </tbody>
        </table>
        
        <div style="background: linear-gradient(to right, #2563eb, #3b82f6); color: white; padding: 20px; border-radius: 5px; text-align: center; margin-bottom: 20px;">
          <p style="margin: 0 0 10px 0; opacity: 0.9;">Cumulative GPA (MSU-TCTO)</p>
          <p style="margin: 0; font-size: 36px; font-weight: bold;">{gpa:.2f}</p>
        </div>
        
        {f'<div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin-bottom: 20px;"><p><strong>Message from Instructor:</strong></p><p>{custom_message}</p></div>' if custom_message else ''}
        
        <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;">
        <p style="color: #6b7280; font-size: 11px; text-align: center;">This is an official transcript from EduScan. Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
      </body>
    </html>
    """
    
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
