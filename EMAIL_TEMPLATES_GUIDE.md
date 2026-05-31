# Enhanced Email Templates Documentation

## Overview

The EduScan system now includes **professional report card-style email templates** for grade reports and transcripts. These templates feature:

- ✅ Modern gradient headers with purple/blue theme
- ✅ Professional report card layout
- ✅ Color-coded grades (Green for A, Blue for B, Amber for C, Red for F)
- ✅ GPA display with color coding
- ✅ Student information cards
- ✅ Responsive design for all devices
- ✅ Instructor message support
- ✅ Professional footer with timestamp

---

## Template 1: Grade Report Email

### Visual Layout

```
┌─────────────────────────────────────────────────────────┐
│  [PURPLE GRADIENT HEADER]                               │
│  📊 Grade Report                                         │
│  EduScan Academic System                                 │
└─────────────────────────────────────────────────────────┘
│                                                           │
│  Dear Juan Dela Cruz,                                    │
│                                                           │
│  Your grade report for CS101 - Introduction to           │
│  Computer Science is now available.                      │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Exam Name          │ Midterm Examination             │ │
│  │ Subject Code       │ CS101                           │ │
│  │ Subject Name       │ Introduction to Computer...     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                                                     │ │
│  │              Your Grade                            │ │
│  │                  A                                 │ │
│  │              92.5%                                 │ │
│  │          Grade Point: 4.00                         │ │
│  │                                                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │              PASSED                                │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 📝 Message from Instructor:                         │ │
│  │ Excellent performance! Keep up the great work...   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  If you have any questions about your grade, please     │
│  contact your instructor or visit the EduScan portal.   │
│                                                           │
├─────────────────────────────────────────────────────────┤
│ This is an automated message from EduScan               │
│ Generated on December 19, 2024 at 02:30 PM             │
└─────────────────────────────────────────────────────────┘
```

### Features

- **Header**: Purple gradient with "📊 Grade Report" title
- **Student Greeting**: Personalized with student name
- **Report Card**: Clean table showing exam details
- **Grade Display**: Large, color-coded grade with percentage and GPA
- **Status Badge**: "PASSED" or "FAILED" with appropriate color
- **Instructor Message**: Optional custom message in highlighted box
- **Footer**: Timestamp and system information

### Color Coding

| Grade Range | Color | Background |
|-------------|-------|------------|
| 90-100% (A) | Green (#10b981) | Light Green (#ecfdf5) |
| 80-89% (B) | Blue (#3b82f6) | Light Blue (#eff6ff) |
| 70-79% (C) | Amber (#f59e0b) | Light Amber (#fffbeb) |
| Below 70% | Red (#ef4444) | Light Red (#fef2f2) |

---

## Template 2: Official Grade Transcript

### Visual Layout

```
┌─────────────────────────────────────────────────────────┐
│  [PURPLE GRADIENT HEADER]                               │
│  📜 Official Grade Transcript                            │
│  EduScan Academic System                                 │
│  ═══════════════════════════════════════════════════════ │
└─────────────────────────────────────────────────────────┘
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Student Name    │ Juan Dela Cruz                    │ │
│  │ Student ID      │ 2024-001234                       │ │
│  │ Course          │ Bachelor of Science in CS         │ │
│  │ Year Level      │ 2nd Year                          │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  📚 Academic Record                                      │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Subject Code │ Subject Name │ Units │ Avg Grade    │ │
│  ├─────────────────────────────────────────────────────┤ │
│  │ CS101        │ Intro to CS  │   3   │   92.50%     │ │
│  │ MATH201      │ Calculus II  │   4   │   88.75%     │ │
│  │ ENG102       │ English Comp │   3   │   85.00%     │ │
│  │ PHYS101      │ Physics I    │   4   │   90.25%     │ │
│  │ CHEM101      │ Chemistry I  │   3   │   87.50%     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                                                     │ │
│  │          Cumulative GPA                            │ │
│  │              3.68                                  │ │
│  │          Scale: 0.00 - 4.00                        │ │
│  │                                                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 📝 Message from Instructor:                         │ │
│  │ Your academic performance this semester has been   │ │
│  │ outstanding. Continue to maintain this excellent   │ │
│  │ standard...                                         │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  This is your official academic transcript from EduScan. │
│  For inquiries, please contact your academic advisor.    │
│                                                           │
├─────────────────────────────────────────────────────────┤
│ Official Document - EduScan Academic System             │
│ Generated on December 19, 2024 at 02:30 PM             │
└─────────────────────────────────────────────────────────┘
```

### Features

- **Header**: Purple gradient with "📜 Official Grade Transcript" title
- **Student Info Card**: All student details in organized format
- **Academic Record Table**: All subjects with units and grades
- **GPA Display**: Large, color-coded GPA with scale information
- **Instructor Message**: Optional custom message
- **Professional Footer**: Official document designation with timestamp

### GPA Color Coding

| GPA Range | Color | Background |
|-----------|-------|------------|
| 3.5-4.0 | Green (#10b981) | Light Green (#ecfdf5) |
| 3.0-3.49 | Blue (#3b82f6) | Light Blue (#eff6ff) |
| 2.5-2.99 | Amber (#f59e0b) | Light Amber (#fffbeb) |
| Below 2.5 | Red (#ef4444) | Light Red (#fef2f2) |

---

## Setup Instructions

### 1. Gmail Configuration

To send emails, you need to configure Gmail SMTP credentials:

#### Step 1: Enable 2-Factor Authentication
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification

#### Step 2: Create App Password
1. Go to https://myaccount.google.com/apppasswords
2. Select "Mail" and "Windows Computer"
3. Google will generate a 16-character password
4. Copy this password

#### Step 3: Update .env File
```bash
# backend/.env
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=xxxx xxxx xxxx xxxx  # 16-character app password
```

### 2. Using the Templates

#### In Your Code

```python
from email_templates import grade_report_template, transcript_template

# Send grade report
html = grade_report_template(
    student_name="Juan Dela Cruz",
    exam_name="Midterm Examination",
    subject_code="CS101",
    subject_name="Introduction to Computer Science",
    percentage=92.5,
    grade="A",
    grade_point=4.0,
    remarks="Passed",
    custom_message="Excellent performance! Keep up the great work."
)

# Send transcript
html = transcript_template(
    student_name="Juan Dela Cruz",
    student_id="2024-001234",
    course="Bachelor of Science in Computer Science",
    year_level="2nd Year",
    transcript_rows=transcript_rows_html,
    gpa=3.68,
    custom_message="Your performance has been outstanding."
)
```

---

## Testing

### Run Test Script

```bash
cd backend
python test_email_templates.py
```

This will send example emails to `kayting4k@gmail.com` showing:
1. Grade Report for CS101 (92.5% - A grade)
2. Official Transcript with 5 subjects and 3.68 GPA

### Expected Output

```
============================================================
[EMAIL] EduScan Email Template Test
============================================================

Sending test emails to: kayting4k@gmail.com

[SENDING] Example grade report...
[SUCCESS] Email sent successfully to kayting4k@gmail.com

[SENDING] Example transcript...
[SUCCESS] Email sent successfully to kayting4k@gmail.com

============================================================
[SUCCESS] All test emails sent successfully!

Check your inbox for:
  1. Grade Report - CS101 Introduction to Computer Science
  2. Official Grade Transcript - Juan Dela Cruz
============================================================
```

---

## API Endpoints

### Send Grade Report

```http
POST /email/send-grade-report
Content-Type: application/json

{
  "student_id": "uuid",
  "exam_name": "Midterm Examination",
  "subject_code": "CS101",
  "subject_name": "Introduction to Computer Science",
  "percentage": 92.5,
  "grade": "A",
  "grade_point": 4.0,
  "remarks": "Passed",
  "custom_message": "Optional message from instructor"
}
```

### Send Grade Transcript

```http
POST /email/send-grade-transcript?student_id=uuid&custom_message=Optional+message
```

### Send Bulk Reports

```http
POST /email/send-bulk-reports
Content-Type: application/json

[
  {
    "student_id": "uuid1",
    "exam_name": "Midterm",
    "subject_code": "CS101",
    "subject_name": "Intro to CS",
    "percentage": 92.5,
    "grade": "A",
    "grade_point": 4.0,
    "remarks": "Passed"
  },
  {
    "student_id": "uuid2",
    ...
  }
]
```

---

## Files

- **email_templates.py** - Template functions for grade reports and transcripts
- **test_email_templates.py** - Test script to send example emails
- **controllers/email.py** - API endpoints for sending emails

---

## Troubleshooting

### Gmail Authentication Failed

**Error**: `Username and Password not accepted`

**Solution**:
1. Verify you're using an **app password**, not your regular Gmail password
2. Check that 2-Factor Authentication is enabled
3. Verify credentials in `.env` file are correct
4. Try regenerating the app password

### Email Not Received

**Possible causes**:
1. Check spam/junk folder
2. Verify recipient email address is correct
3. Check Gmail SMTP server status
4. Verify internet connection

### Template Not Rendering

**Solution**:
1. Ensure HTML is properly formatted
2. Test with a simple email client first
3. Check for special characters that need escaping

---

## Customization

### Change Colors

Edit `email_templates.py` and modify the color values:

```python
# Grade colors
if percentage >= 90:
    grade_color = "#10b981"  # Change this
    grade_bg = "#ecfdf5"     # And this
```

### Change Header

Modify the header section in the template:

```python
<div class="header">
    <h1>📊 Grade Report</h1>  <!-- Change title -->
    <p>EduScan Academic System</p>  <!-- Change subtitle -->
</div>
```

### Add More Sections

Add new rows to the report card:

```python
<div class="report-row">
    <span class="report-label">New Field</span>
    <span class="report-value">Value</span>
</div>
```

---

## Next Steps

1. ✅ Configure Gmail credentials in `.env`
2. ✅ Run `test_email_templates.py` to verify setup
3. ✅ Integrate templates into your application
4. ✅ Test with real student data
5. ✅ Deploy to production

---

**Created**: December 19, 2024
**Version**: 1.0
**Status**: Production Ready
