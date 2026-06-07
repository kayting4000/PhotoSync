# Email Templates - Visual Preview

## Summary

Your PhotoSync system now has **professional report card-style email templates** that look modern and polished. The old plain text emails have been replaced with:

✅ **Grade Report Email** - Individual exam results with color-coded grades
✅ **Official Transcript Email** - Complete academic record with GPA calculation
✅ **Professional Design** - Purple gradient headers, clean layouts, responsive
✅ **Color Coding** - Green (A), Blue (B), Amber (C), Red (F)

---

## Email 1: Grade Report

### What It Shows

When a student receives a grade report, they see:

```
┌─────────────────────────────────────────────────────────────┐
│                                                               │
│  [PURPLE GRADIENT BACKGROUND]                                │
│                                                               │
│                    📊 Grade Report                            │
│              PhotoSync Academic System                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Dear Juan Dela Cruz,

Your grade report for CS101 - Introduction to Computer Science 
is now available. Please review your performance details below.

┌─────────────────────────────────────────────────────────────┐
│  Exam Name              │  Midterm Examination                │
│  Subject Code           │  CS101                              │
│  Subject Name           │  Introduction to Computer Science   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                                                               │
│                    Your Grade                                │
│                        A                                     │
│                     92.5%                                    │
│                Grade Point: 4.00                             │
│                                                               │
│  [GREEN BACKGROUND - Color coded by grade]                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      PASSED                                  │
│              [GREEN BACKGROUND]                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📝 Message from Instructor:                                 │
│                                                               │
│  Excellent performance! Keep up the great work and maintain  │
│  this level of excellence.                                   │
│                                                               │
│  [AMBER/YELLOW BACKGROUND]                                   │
└─────────────────────────────────────────────────────────────┘

If you have any questions about your grade, please contact 
your instructor or visit the PhotoSync portal to view more 
details about your academic performance.

─────────────────────────────────────────────────────────────

This is an automated message from PhotoSync Academic System
Generated on December 19, 2024 at 02:30 PM
```

### Grade Color Examples

| Grade | Percentage | Color | Background |
|-------|-----------|-------|------------|
| A | 92.5% | 🟢 Green | Light Green |
| B | 88.0% | 🔵 Blue | Light Blue |
| C | 75.0% | 🟡 Amber | Light Amber |
| F | 65.0% | 🔴 Red | Light Red |

---

## Email 2: Official Grade Transcript

### What It Shows

When a student receives their transcript, they see:

```
┌─────────────────────────────────────────────────────────────┐
│                                                               │
│  [PURPLE GRADIENT BACKGROUND]                                │
│                                                               │
│              📜 Official Grade Transcript                     │
│              PhotoSync Academic System                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Student Name    │  Juan Dela Cruz                            │
│  Student ID      │  2024-001234                               │
│  Course          │  Bachelor of Science in Computer Science   │
│  Year Level      │  2nd Year                                  │
└─────────────────────────────────────────────────────────────┘

📚 Academic Record

┌─────────────────────────────────────────────────────────────┐
│ Subject Code │ Subject Name │ Units │ Average Grade          │
├─────────────────────────────────────────────────────────────┤
│ CS101        │ Intro to CS  │   3   │    92.50%              │
│ MATH201      │ Calculus II  │   4   │    88.75%              │
│ ENG102       │ English Comp │   3   │    85.00%              │
│ PHYS101      │ Physics I    │   4   │    90.25%              │
│ CHEM101      │ Chemistry I  │   3   │    87.50%              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                                                               │
│              Cumulative GPA                                  │
│                  3.68                                        │
│            Scale: 0.00 - 4.00                                │
│                                                               │
│  [BLUE BACKGROUND - Color coded by GPA]                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📝 Message from Instructor:                                 │
│                                                               │
│  Your academic performance this semester has been            │
│  outstanding. Continue to maintain this excellent standard   │
│  and explore advanced courses in your field of interest.     │
│                                                               │
│  [AMBER/YELLOW BACKGROUND]                                   │
└─────────────────────────────────────────────────────────────┘

This is your official academic transcript from PhotoSync. It 
contains a complete record of your grades and academic 
performance. For inquiries or clarifications, please contact 
your academic advisor.

─────────────────────────────────────────────────────────────

📋 Official Document - PhotoSync Academic System
Generated on December 19, 2024 at 02:30 PM
```

### GPA Color Examples

| GPA Range | Color | Background |
|-----------|-------|------------|
| 3.5-4.0 | 🟢 Green | Light Green |
| 3.0-3.49 | 🔵 Blue | Light Blue |
| 2.5-2.99 | 🟡 Amber | Light Amber |
| Below 2.5 | 🔴 Red | Light Red |

---

## Key Features

### 1. Professional Design
- Modern purple gradient header
- Clean, organized layout
- Proper spacing and typography
- Responsive for all devices

### 2. Color Coding
- Grades automatically color-coded
- GPA automatically color-coded
- Visual hierarchy with colors
- Easy to scan and understand

### 3. Student Information
- Personalized greeting
- Complete student details
- Subject information
- Grade breakdown

### 4. Instructor Messages
- Optional custom messages
- Highlighted in amber box
- Professional tone
- Encouragement or feedback

### 5. Professional Footer
- Official document designation
- Timestamp
- System branding
- Contact information

---

## How to Send

### Via API

**Send Grade Report:**
```bash
curl -X POST http://localhost:8000/email/send-grade-report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "student_id": "uuid",
    "exam_name": "Midterm Examination",
    "subject_code": "CS101",
    "subject_name": "Introduction to Computer Science",
    "percentage": 92.5,
    "grade": "A",
    "grade_point": 4.0,
    "remarks": "Passed",
    "custom_message": "Excellent work!"
  }'
```

**Send Transcript:**
```bash
curl -X POST "http://localhost:8000/email/send-grade-transcript?student_id=uuid&custom_message=Great+semester" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Send Bulk Reports:**
```bash
curl -X POST http://localhost:8000/email/send-bulk-reports \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '[
    {
      "student_id": "uuid1",
      "exam_name": "Midterm",
      "subject_code": "CS101",
      "subject_name": "Intro to CS",
      "percentage": 92.5,
      "grade": "A",
      "grade_point": 4.0,
      "remarks": "Passed"
    }
  ]'
```

---

## Setup Required

### 1. Gmail Configuration

Add to `backend/.env`:
```
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=xxxx xxxx xxxx xxxx
```

### 2. Get App Password

1. Enable 2-Factor Authentication on Gmail
2. Go to https://myaccount.google.com/apppasswords
3. Select "Mail" and "Windows Computer"
4. Copy the 16-character password
5. Paste into `.env` file

### 3. Test

```bash
cd backend
python test_email_templates.py
```

---

## Files Created/Updated

| File | Purpose |
|------|---------|
| `email_templates.py` | Template functions for grade reports and transcripts |
| `test_email_templates.py` | Test script to send example emails |
| `controllers/email.py` | Updated to use new templates |
| `EMAIL_TEMPLATES_GUIDE.md` | Complete documentation |

---

## Comparison: Old vs New

### Old Email
```
Plain text table
Basic formatting
No colors
Generic layout
```

### New Email
```
✅ Professional gradient header
✅ Color-coded grades and GPA
✅ Modern card-based layout
✅ Responsive design
✅ Instructor messages
✅ Professional footer
✅ Better visual hierarchy
```

---

## Next Steps

1. ✅ Configure Gmail credentials in `.env`
2. ✅ Run test script: `python test_email_templates.py`
3. ✅ Check your inbox for example emails
4. ✅ Integrate into your application
5. ✅ Send real grade reports to students

---

**Status**: ✅ Production Ready
**Version**: 1.0
**Last Updated**: December 19, 2024
