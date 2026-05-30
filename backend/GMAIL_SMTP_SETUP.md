# 📧 Gmail SMTP Setup Guide for EduScan

## Overview

EduScan uses Gmail SMTP to send grade reports and transcripts to students. This guide walks you through the setup process.

---

## 🔧 Step-by-Step Setup

### Step 1: Enable 2-Factor Authentication

1. Go to **https://myaccount.google.com**
2. Click **Security** in the left sidebar
3. Scroll to **How you sign in to Google**
4. Click **2-Step Verification**
5. Follow the prompts to enable 2FA

---

### Step 2: Generate App Password

1. Go to **https://myaccount.google.com/apppasswords**
2. Select **Mail** from the dropdown
3. Select **Windows Computer** (or your device type)
4. Click **Generate**
5. Copy the **16-character password** (you'll need this)

**Example:** `abcd efgh ijkl mnop`

---

### Step 3: Configure Environment Variables

Create or update `.env` file in `backend/` folder:

```env
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=abcd efgh ijkl mnop
```

**Important:**
- Use your full Gmail address (including @gmail.com)
- Use the 16-character app password (not your regular password)
- Keep spaces in the app password

---

### Step 4: Verify Configuration

Test the setup by running:

```bash
cd backend
python -c "
import os
from dotenv import load_dotenv
load_dotenv()
print('GMAIL_USER:', os.getenv('GMAIL_USER'))
print('GMAIL_PASSWORD:', '***' if os.getenv('GMAIL_PASSWORD') else 'NOT SET')
"
```

---

## 📧 Gmail SMTP Settings

### Connection Details
```
Server: smtp.gmail.com
Port: 587 (TLS) or 465 (SSL)
Security: TLS (recommended)
Authentication: Required
```

### Current Configuration
- **Server:** smtp.gmail.com
- **Port:** 587 (TLS)
- **Method:** STARTTLS

---

## 🚀 Testing Email Sending

### Test via Swagger UI

1. Start the backend:
```bash
python -m uvicorn main:app --reload
```

2. Open **http://localhost:8000/docs**

3. Find **POST /email/send-grade-report**

4. Click **Try it out**

5. Enter test data:
```json
{
  "student_id": "test-student-id",
  "exam_name": "Midterm Exam",
  "subject_code": "CS101",
  "subject_name": "Programming",
  "percentage": 85.5,
  "grade": "1.75",
  "grade_point": 1.75,
  "remarks": "Passed",
  "custom_message": "Great work!"
}
```

6. Click **Execute**

---

## 🐛 Troubleshooting

### Error: "Gmail authentication failed"

**Cause:** Wrong email or app password

**Solution:**
1. Verify GMAIL_USER is correct (with @gmail.com)
2. Verify GMAIL_PASSWORD is the 16-character app password
3. Check `.env` file has no extra spaces

---

### Error: "Gmail SMTP error: 535 5.7.8 Username and password not accepted"

**Cause:** 2FA not enabled or app password not generated

**Solution:**
1. Enable 2-Factor Authentication (see Step 1)
2. Generate new App Password (see Step 2)
3. Update `.env` with new password

---

### Error: "Connection refused"

**Cause:** Network or firewall issue

**Solution:**
1. Check internet connection
2. Verify firewall allows port 587
3. Try port 465 (SSL) instead

---

### Error: "Email not sent to student"

**Cause:** Student email not in database

**Solution:**
1. Verify student record exists
2. Verify student has email address
3. Check student_id is correct

---

## 📋 Email Features

### 1. Send Grade Report
```
POST /email/send-grade-report
```

Sends a single exam grade to a student.

**Request:**
```json
{
  "student_id": "uuid",
  "exam_name": "Quiz 1",
  "subject_code": "CS101",
  "subject_name": "Programming",
  "percentage": 90,
  "grade": "1.25",
  "grade_point": 1.25,
  "remarks": "Passed",
  "custom_message": "Excellent work!"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Grade report sent to student@example.com"
}
```

---

### 2. Send Grade Transcript
```
POST /email/send-grade-transcript
```

Sends complete academic transcript with GPA.

**Request:**
```
POST /email/send-grade-transcript?student_id=uuid&custom_message=Great%20semester!
```

**Response:**
```json
{
  "success": true,
  "message": "Grade transcript sent to student@example.com",
  "gpa": 2.45
}
```

---

### 3. Send Bulk Reports
```
POST /email/send-bulk-reports
```

Sends grade reports to multiple students.

**Request:**
```json
[
  {
    "student_id": "uuid1",
    "exam_name": "Quiz 1",
    "subject_code": "CS101",
    "subject_name": "Programming",
    "percentage": 90,
    "grade": "1.25",
    "grade_point": 1.25,
    "remarks": "Passed"
  },
  {
    "student_id": "uuid2",
    "exam_name": "Quiz 1",
    "subject_code": "CS101",
    "subject_name": "Programming",
    "percentage": 75,
    "grade": "2.5",
    "grade_point": 2.5,
    "remarks": "Passed"
  }
]
```

**Response:**
```json
{
  "results": [
    {
      "student_id": "uuid1",
      "success": true,
      "message": "Grade report sent to student1@example.com"
    },
    {
      "student_id": "uuid2",
      "success": true,
      "message": "Grade report sent to student2@example.com"
    }
  ]
}
```

---

## 📧 Email Templates

### Grade Report Email
- Student name
- Exam details (name, subject, percentage)
- Grade and grade point
- Pass/Fail status
- Optional custom message

### Grade Transcript Email
- Student information (name, ID, course, year)
- Complete academic record table
- All subjects with units and grades
- Cumulative GPA (MSU-TCTO)
- Optional custom message
- Generation timestamp

---

## 🔒 Security Best Practices

1. **Never commit `.env` file** - Add to `.gitignore`
2. **Use App Password** - Not your regular Gmail password
3. **Enable 2FA** - Required for app passwords
4. **Rotate passwords** - Change app password periodically
5. **Limit access** - Only share credentials with trusted team members

---

## 📱 Alternative Email Services

If you want to use a different email service:

### Option 1: Office 365 / Outlook
```
Server: smtp.office365.com
Port: 587
```

### Option 2: SendGrid
```
Server: smtp.sendgrid.net
Port: 587
Username: apikey
Password: SG.xxxxx
```

### Option 3: AWS SES
```
Server: email-smtp.region.amazonaws.com
Port: 587
```

---

## 📞 Support

### Common Issues

| Issue | Solution |
|-------|----------|
| "Not an app password" | Generate new app password from myaccount.google.com/apppasswords |
| "2-Step verification not enabled" | Enable 2FA first at myaccount.google.com/security |
| "Connection timeout" | Check firewall allows port 587 |
| "Email not received" | Check student email is correct in database |

---

## 🧪 Testing Checklist

- [ ] 2FA enabled on Gmail account
- [ ] App password generated
- [ ] `.env` file configured
- [ ] Backend starts without errors
- [ ] Swagger UI accessible at `/docs`
- [ ] Test email sends successfully
- [ ] Email received in student inbox
- [ ] Email formatting looks correct
- [ ] Bulk emails work
- [ ] Transcripts include GPA

---

## 📚 References

- [Gmail App Passwords](https://support.google.com/accounts/answer/185833)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)
- [Python smtplib Documentation](https://docs.python.org/3/library/smtplib.html)
- [FastAPI Email Integration](https://fastapi.tiangolo.com/)

---

## 🎯 Next Steps

1. ✅ Enable 2FA on Gmail
2. ✅ Generate app password
3. ✅ Configure `.env` file
4. ✅ Test email sending
5. ✅ Deploy to production

---

**Version:** 2024.12.19+1
**Last Updated:** December 19, 2024
**Status:** ✅ Production Ready

