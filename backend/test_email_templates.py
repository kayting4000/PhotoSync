"""
Test script to send example grade report and transcript emails.
Demonstrates the enhanced report card-style email templates.
"""
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv
from email_templates import grade_report_template, transcript_template

load_dotenv()

GMAIL_USER = os.getenv("GMAIL_USER")
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD")
GMAIL_SMTP_SERVER = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

def send_test_email(to_email: str, subject: str, html_content: str):
    """Send test email via Gmail SMTP."""
    if not GMAIL_USER or not GMAIL_PASSWORD:
        print("[ERROR] Gmail credentials not configured!")
        print("Set GMAIL_USER and GMAIL_PASSWORD in .env file")
        return False
    
    try:
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = GMAIL_USER
        msg['To'] = to_email
        msg.attach(MIMEText(html_content, 'html'))
        
        with smtplib.SMTP(GMAIL_SMTP_SERVER, GMAIL_SMTP_PORT) as server:
            server.starttls()
            server.login(GMAIL_USER, GMAIL_PASSWORD)
            server.send_message(msg)
        
        print(f"[SUCCESS] Email sent successfully to {to_email}")
        return True
        
    except Exception as e:
        print(f"[ERROR] Failed to send email: {str(e)}")
        return False


def send_example_grade_report(to_email: str):
    """Send example grade report email."""
    print("\n[SENDING] Example grade report...")
    
    html = grade_report_template(
        student_name="Juan Dela Cruz",
        exam_name="Midterm Examination",
        subject_code="CS101",
        subject_name="Introduction to Computer Science",
        percentage=92.5,
        grade="A",
        grade_point=4.0,
        remarks="Passed",
        custom_message="Excellent performance! Keep up the great work and maintain this level of excellence."
    )
    
    return send_test_email(
        to_email=to_email,
        subject="Grade Report - CS101 Introduction to Computer Science",
        html_content=html
    )


def send_example_transcript(to_email: str):
    """Send example transcript email."""
    print("\n[SENDING] Example transcript...")
    
    # Build transcript rows
    transcript_rows = """
    <tr>
      <td>CS101</td>
      <td>Introduction to Computer Science</td>
      <td style="text-align: center;">3</td>
      <td style="text-align: center;">92.50%</td>
    </tr>
    <tr>
      <td>MATH201</td>
      <td>Calculus II</td>
      <td style="text-align: center;">4</td>
      <td style="text-align: center;">88.75%</td>
    </tr>
    <tr>
      <td>ENG102</td>
      <td>English Composition</td>
      <td style="text-align: center;">3</td>
      <td style="text-align: center;">85.00%</td>
    </tr>
    <tr>
      <td>PHYS101</td>
      <td>Physics I</td>
      <td style="text-align: center;">4</td>
      <td style="text-align: center;">90.25%</td>
    </tr>
    <tr>
      <td>CHEM101</td>
      <td>Chemistry I</td>
      <td style="text-align: center;">3</td>
      <td style="text-align: center;">87.50%</td>
    </tr>
    """
    
    html = transcript_template(
        student_name="Juan Dela Cruz",
        student_id="2024-001234",
        course="Bachelor of Science in Computer Science",
        year_level="2nd Year",
        transcript_rows=transcript_rows,
        gpa=3.68,
        custom_message="Your academic performance this semester has been outstanding. Continue to maintain this excellent standard and explore advanced courses in your field of interest."
    )
    
    return send_test_email(
        to_email=to_email,
        subject="Official Grade Transcript - Juan Dela Cruz",
        html_content=html
    )


if __name__ == "__main__":
    recipient_email = "kayting4k@gmail.com"
    
    print("=" * 60)
    print("[EMAIL] EduScan Email Template Test")
    print("=" * 60)
    print(f"\nSending test emails to: {recipient_email}")
    
    # Send grade report
    grade_report_sent = send_example_grade_report(recipient_email)
    
    # Send transcript
    transcript_sent = send_example_transcript(recipient_email)
    
    print("\n" + "=" * 60)
    if grade_report_sent and transcript_sent:
        print("[SUCCESS] All test emails sent successfully!")
        print("\nCheck your inbox for:")
        print("  1. Grade Report - CS101 Introduction to Computer Science")
        print("  2. Official Grade Transcript - Juan Dela Cruz")
    else:
        print("[WARNING] Some emails failed to send. Check the errors above.")
    print("=" * 60)
