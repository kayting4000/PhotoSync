# PhotoSync Grades & Email Features

## 📊 Hierarchical Grade Viewing (MSU-TCTO)

The grades system now supports a **three-level hierarchy** for viewing student grades:

### Level 1: Student Overview
**Endpoint:** `GET /grades/student/{student_id}`

Shows all subjects and exams for a student, grouped by subject.

**Response includes:**
- Student information (name, ID, course, year level)
- List of all subjects with:
  - Subject code, name, units
  - All exams in that subject
  - Average percentage and grade for the subject

**Use case:** Teacher wants to see all grades for one student at a glance.

---

### Level 2: Subject Details
**Endpoint:** `GET /grades/student/{student_id}/subject/{subject_id}`

Shows detailed breakdown of all exams in a specific subject for a student.

**Response includes:**
- Student and subject information
- Detailed exam list with:
  - Exam name and type (quiz, midterm, final, assignment)
  - Total items, points per item
  - Correct answers, total score, percentage
  - Grade and grade point (MSU-TCTO scale)
  - Remarks (Passed/Failed)
- Subject average (percentage, grade point, final grade)

**Use case:** Teacher wants to see how a student performed in one specific subject.

---

### Level 3: GPA Calculation
**Endpoint:** `GET /grades/student/{student_id}/gpa`

Calculates the student's cumulative GPA using the **MSU-TCTO formula**.

**Formula:**
```
GPA = Σ(grade_point × units) / Σ(units)
```

**Response includes:**
- Student name and ID
- Overall GPA (0.0 to 5.0)
- GPA interpretation (Excellent, Very Good, Good, Satisfactory, Passing, Failed)
- Total units completed
- Breakdown by subject with average grade point

**Use case:** Teacher needs to check a student's overall academic standing.

---

## 🎓 MSU-TCTO Grading Scale

The system uses the official **Mindanao State University - Tawi-Tawi College of Technology and Oceanography** grading scale:

| Percentage | Grade | Grade Point | Description |
|------------|-------|-------------|-------------|
| 96–100 | 1.0 | 1.0 | Excellent |
| 92–95 | 1.25 | 1.25 | Very Good |
| 88–91 | 1.5 | 1.5 | Good |
| 84–87 | 1.75 | 1.75 | Good |
| 80–83 | 2.0 | 2.0 | Satisfactory |
| 76–79 | 2.25 | 2.25 | Satisfactory |
| 72–75 | 2.5 | 2.5 | Satisfactory |
| 68–71 | 2.75 | 2.75 | Passing |
| 60–67 | 3.0 | 3.0 | Passing |
| Below 60 | 5.0 | 5.0 | Failed |

---

## 📧 Enhanced Email Features

### Feature 1: Individual Grade Report
**Endpoint:** `POST /email/send-grade-report`

Sends a single exam grade report to a student.

**Request body:**
```json
{
  "student_id": "uuid",
  "exam_name": "Midterm Exam",
  "subject_code": "CS101",
  "subject_name": "Introduction to Programming",
  "percentage": 85.5,
  "grade": "1.75",
  "grade_point": 1.75,
  "remarks": "Passed",
  "custom_message": "Great effort! Keep it up."
}
```

**Email includes:**
- Student name
- Exam details (name, subject, percentage, grade)
- Pass/Fail status with color coding
- Optional custom message from teacher

---

### Feature 2: Complete Grade Transcript ⭐ NEW
**Endpoint:** `POST /email/send-grade-transcript`

Sends a **complete academic transcript** to a student with all subjects, exams, and GPA.

**Request parameters:**
- `student_id` (required)
- `custom_message` (optional) - Message from instructor

**Email includes:**
- Student information (name, ID, course, year level)
- Complete academic record table with:
  - Subject code and name
  - Units
  - Average grade for each subject
- **Cumulative GPA (MSU-TCTO)** prominently displayed
- Optional custom message
- Generation timestamp

**Use case:** 
- End of semester grade distribution
- Student requests official transcript
- Parent-teacher communication
- Academic standing verification

---

### Feature 3: Bulk Email Sending
**Endpoint:** `POST /email/send-bulk-reports`

Send grade reports to multiple students at once.

**Request body:**
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

**Response includes:**
- Success/failure status for each student
- Error messages if any failed

---

## 🔧 Configuration

### Gmail SMTP Setup

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password:**
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Copy the 16-character password

3. **Set environment variables** in `.env`:
```
GMAIL_USER=your-email@gmail.com
GMAIL_PASSWORD=your-16-char-app-password
```

4. **Restart the backend server**

---

## 📋 Presentation Flow

### Demo Sequence:

1. **Show Hierarchical Grades:**
   - Open Swagger UI
   - Call `GET /grades/student/{student_id}` → Show all subjects
   - Call `GET /grades/student/{student_id}/subject/{subject_id}` → Show exam details
   - Call `GET /grades/student/{student_id}/gpa` → Show GPA calculation

2. **Explain MSU-TCTO Scale:**
   - Point out the grading table in the response
   - Explain: "A 90% score becomes grade 1.25 (Very Good) with 1.25 grade points"

3. **Demo Email Features:**
   - Call `POST /email/send-grade-report` → Show email sent
   - Call `POST /email/send-grade-transcript` → Show complete transcript email
   - Explain: "Teachers can send individual grades or complete transcripts to students"

4. **Highlight Key Features:**
   - "Grades are organized hierarchically - easy to navigate"
   - "MSU-TCTO grading scale is automatically applied"
   - "GPA calculation is accurate and transparent"
   - "Email features support both individual and bulk sending"

---

## 🎯 Key Talking Points for Your Professor

1. **Hierarchical Design:** "The system organizes grades in three levels - student overview, subject details, and GPA - making it easy to find what you need."

2. **MSU-TCTO Compliance:** "We implemented the official MSU-TCTO grading scale, so grades are calculated exactly as your institution requires."

3. **Automated Calculations:** "GPA is calculated automatically using the weighted formula, eliminating manual computation errors."

4. **Communication:** "Teachers can send individual grade reports or complete transcripts to students via email, improving transparency."

5. **Data Integrity:** "Each grade is linked to the exam, subject, and student, ensuring data consistency across the system."

---

## 📝 Example API Calls

### Get all grades for a student:
```bash
curl -X GET "http://localhost:8000/grades/student/abc123" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get grades for a specific subject:
```bash
curl -X GET "http://localhost:8000/grades/student/abc123/subject/xyz789" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get student GPA:
```bash
curl -X GET "http://localhost:8000/grades/student/abc123/gpa" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Send grade transcript:
```bash
curl -X POST "http://localhost:8000/email/send-grade-transcript?student_id=abc123&custom_message=Great%20work!" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ✅ Testing Checklist

- [ ] Hierarchical grade endpoints return correct data
- [ ] MSU-TCTO grades are calculated correctly
- [ ] GPA calculation matches manual verification
- [ ] Gmail SMTP credentials are configured
- [ ] Grade report emails send successfully
- [ ] Grade transcript emails include all subjects and GPA
- [ ] Bulk email sending works for multiple students
- [ ] Custom messages appear in emails
- [ ] Email formatting is professional and readable

