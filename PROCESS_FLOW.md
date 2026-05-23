# EduScan Process Flow Documentation

This document maps out the complete flow of the EduScan application - from user authentication through grade reporting.

## 1. Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   AUTHENTICATION FLOW                        │
└─────────────────────────────────────────────────────────────┘

USER SIGNUP:
   User visits /auth/sign-up
       ↓
   Frontend form: email + password
       ↓
   POST /auth/signup (to backend)
       ↓
   Backend validates and creates user
       ↓
   Returns: { access_token, user: { id, email } }
       ↓
   Frontend stores in localStorage:
   ├─ access_token (for API calls)
   └─ user (for display)
       ↓
   Redirects to /auth/sign-up-success → /dashboard

USER LOGIN:
   User visits /auth/login
       ↓
   Enters email/password
       ↓
   POST /auth/login (to backend)
       ↓
   Backend validates credentials
       ↓
   Returns: { access_token, user: { id, email } }
       ↓
   Frontend stores token and user in localStorage
       ↓
   Redirects to /dashboard

SESSION MANAGEMENT:
   On every page load:
   ├─ Check localStorage for access_token
   ├─ If token exists → authenticated
   └─ If token missing → redirect to /auth/login

LOGOUT:
   User clicks Sign Out
       ↓
   Clear localStorage:
   ├─ Remove access_token
   ├─ Remove user
       ↓
   Redirect to /auth/login

✅ Uses JWT tokens from backend
✅ No Supabase dependency
✅ Simple and secure
```

---

## 2. Dashboard & Navigation Flow

```
┌─────────────────────────────────────────────────────────────┐
│              DASHBOARD & NAVIGATION FLOW                     │
└─────────────────────────────────────────────────────────────┘

User Authenticated
       ↓
   /dashboard/page.tsx
       ↓
   Queries Supabase for:
   ├─ students.count()
   ├─ subjects.count()
   ├─ exams.count()
   └─ exam_results.count()
       ↓
   Displays Dashboard with Stats:
   ├─ Total Students (links to /dashboard/students)
   ├─ Subjects (links to /dashboard/subjects)
   ├─ Exams Created (links to /dashboard/subjects)
   └─ Results Recorded (links to /dashboard/grades)
       ↓
   Quick Actions Menu:
   ├─ Add Student → /dashboard/students?action=add
   ├─ Scan Test Paper → /dashboard/scanner
   ├─ Calculate GPA → /dashboard/grades
   └─ Send Results → /dashboard/email
```

---

## 3. Student Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│            STUDENT MANAGEMENT FLOW                           │
└─────────────────────────────────────────────────────────────┘

View Students:
   /dashboard/students
       ↓
   Loads: StudentsTable component
       ↓
   Queries Supabase: students.select("*").eq("user_id", currentUser.id)
       ↓
   Displays Table with:
   ├─ Student ID
   ├─ Name (First + Last)
   ├─ Email
   ├─ Course
   ├─ Year Level
   └─ Actions (Edit, Delete)
       ↓
   User can Search by: ID, Name, or Course

ADD STUDENT:
   User clicks "Add Student" or ?action=add
       ↓
   Dialog opens: add-student-dialog.tsx
       ↓
   User fills:
   ├─ Student ID (required)
   ├─ First Name (required)
   ├─ Last Name (required)
   ├─ Email (optional but recommended)
   ├─ Course (required)
   └─ Year Level (1-4)
       ↓
   Validates form
       ↓
   Inserts into Supabase: students.insert({...})
       ↓
   Page refreshes with new student
       ↓
   Toast notification: "Student added"

EDIT STUDENT:
   User clicks Edit icon
       ↓
   Dialog opens: edit-student-dialog.tsx
       ↓
   Prefills with current student data
       ↓
   User modifies fields
       ↓
   Saves: students.update({...}).eq("id", studentId)
       ↓
   Toast notification: "Student updated"

DELETE STUDENT:
   User clicks Delete icon
       ↓
   Confirmation dialog appears
       ↓
   Confirms deletion
       ↓
   Deletes: students.delete().eq("id", studentId)
       ↓
   Toast notification: "Student deleted"
```

---

## 4. Subject & Exam Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│         SUBJECT & EXAM MANAGEMENT FLOW                       │
└─────────────────────────────────────────────────────────────┘

MANAGE SUBJECTS:
   /dashboard/subjects
       ↓
   subjects-manager.tsx component
       ↓
   Displays list of subjects with:
   ├─ Subject Code
   ├─ Name
   ├─ Units/Credits
   └─ Actions (Add, Edit, Delete)
       ↓
   Can add/edit subjects
       ↓
   Stores in Supabase: subjects table

MANAGE EXAMS:
   /dashboard/subjects (same page)
       ↓
   Shows exams for each subject:
   ├─ Exam Name
   ├─ Total Items/Questions
   ├─ Points per Item
   ├─ Passing Score
   └─ Actions (Edit, Delete)
       ↓
   Can add new exam for subject
       ↓
   Calculates: max_score = total_items × points_per_item
       ↓
   Stores in Supabase: exams table (with subject_id reference)
```

---

## 5. Scanner & Grading Flow ⭐ (CRITICAL PROCESS)

```
┌─────────────────────────────────────────────────────────────┐
│           SCANNER & GRADING FLOW                             │
└─────────────────────────────────────────────────────────────┘

USER NAVIGATES TO SCANNER:
   /dashboard/scanner
       ↓
   test-scanner.tsx loads with:
   ├─ Student dropdown (from Supabase students)
   ├─ Exam dropdown (from Supabase exams)
   ├─ Image upload area
   └─ Manual score input (fallback)

METHOD 1: AUTOMATIC DETECTION (PREFERRED)
   User selects student & exam
       ↓
   Uploads test paper image
       ↓
   Frontend: detectCheckMarks(imageData)
   ├─ Converts image to grayscale
   ├─ Identifies dark pixels (check marks)
   ├─ Groups pixels into clusters
   ├─ Counts clusters as check marks
   └─ Returns count
       ↓
   OR sends to Roboflow API (if configured):
   POST /scanner/scan
   {
     "image_base64": "..."
   }
       ↓
   Backend: /scanner/scan
   ├─ Sends to Roboflow Workflow API
   ├─ Roboflow detects check marks
   └─ Returns count
       ↓
   Result: count = number of correct answers
       ↓
   Frontend calculates:
   ├─ score = count × points_per_item
   ├─ percentage = (score / max_score) × 100
   └─ grade = assignGrade(percentage)
       ↓
   Shows ScanResult:
   ├─ Check Marks: X
   ├─ Confidence: Y%
   ├─ Score: X/MAX
   ├─ Percentage: X%
   ├─ Grade: [A-F]
   └─ Status: Passed/Failed

METHOD 2: MANUAL INPUT (FALLBACK)
   If automatic detection fails
       ↓
   User can manually enter score
       ↓
   Frontend calculates percentage & grade
       ↓
   Same result display

SAVE RESULT:
   User clicks "Save Result"
       ↓
   Frontend: POST /api/scan/save
   {
     "studentId": "...",
     "examId": "...",
     "correctAnswers": 45,
     "totalScore": 90,
     "percentage": 94.5,
     "grade": "1.25",
     "gradePoint": 1.25,
     "remarks": "Passed",
     "scanImageUrl": "..."
   }
       ↓
   Backend: POST /results/
   ├─ Validates all fields
   ├─ Assigns grade if not provided: _assign_grade(percentage)
   ├─ Creates ExamResult record
   └─ Returns result with ID
       ↓
   Supabase: exam_results.insert({...})
       ↓
   Toast: "Grade saved successfully"
       ↓
   Can view in /dashboard/grades

⚠️  ISSUE: Scanner depends on Roboflow API which may not be configured
```

---

## 6. Grades & GPA Calculation Flow

```
┌─────────────────────────────────────────────────────────────┐
│          GRADES & GPA CALCULATION FLOW                       │
└─────────────────────────────────────────────────────────────┘

VIEW GRADES:
   /dashboard/grades
       ↓
   grades-manager.tsx loads
       ↓
   Queries: exam_results where user_id = currentUser.id
       ↓
   Groups by student
       ↓
   Shows for each result:
   ├─ Student Name
   ├─ Subject Code
   ├─ Exam Name
   ├─ Score (X/MAX)
   ├─ Percentage
   ├─ Grade Letter (1.0-5.0)
   ├─ Status (Passed/Failed)
   └─ Actions (Email, Edit, Delete)

CALCULATE GPA:
   GET /gpa (or API call)
       ↓
   Backend: /gpa controller
   ├─ Queries all ExamResult for current user
   ├─ Filters by student_id if specified
   ├─ For each result:
   │  ├─ Gets grade_point (1.0-5.0)
   │  ├─ Gets units from subject (default: 3)
   │  └─ weighted_sum += grade_point × units
   ├─ total_units += units
   └─ gpa = weighted_sum / total_units
       ↓
   Returns:
   {
     "gpa": 2.15,
     "total_units": 24,
     "subjects_counted": 8,
     "interpretation": "Good"
   }
       ↓
   Frontend displays:
   ├─ Current GPA: 2.15
   ├─ Interpretation: Good
   ├─ Subjects: 8
   └─ Total Units: 24

GRADE SCALE (MSU-Tawi-Tawi):
   ├─ 96-100% → 1.0 (Excellent)
   ├─ 92-95%  → 1.25
   ├─ 88-91%  → 1.5
   ├─ 84-87%  → 1.75
   ├─ 80-83%  → 2.0
   ├─ 76-79%  → 2.25
   ├─ 72-75%  → 2.5
   ├─ 68-71%  → 2.75
   ├─ 60-67%  → 3.0 (Passing)
   └─ <60%    → 5.0 (Failed)

GPA INTERPRETATION:
   ├─ ≤1.25 → Excellent
   ├─ ≤1.75 → Very Good
   ├─ ≤2.25 → Good
   ├─ ≤2.75 → Satisfactory
   ├─ ≤3.0  → Passing
   └─ >3.0  → Failed
```

---

## 7. Email Result Distribution Flow

```
┌─────────────────────────────────────────────────────────────┐
│          EMAIL RESULT DISTRIBUTION FLOW                      │
└─────────────────────────────────────────────────────────────┘

NAVIGATE TO EMAIL:
   /dashboard/email
       ↓
   email-manager.tsx loads
       ↓
   Queries Supabase for:
   ├─ All students
   ├─ All subjects
   └─ All exam results

SELECT SUBJECT:
   User selects subject from dropdown
       ↓
   Component filters results by subject_id
       ↓
   Shows table of students with:
   ├─ Student Name & ID
   ├─ Average Percentage
   ├─ Final Grade
   ├─ Number of exams
   └─ Checkbox (select for bulk email)

COMPOSE & SEND:
   User selects students to email
       ↓
   User can add custom message (optional)
       ↓
   Clicks "Send Emails"
       ↓
   For each selected student:
   ├─ Sets status: "sending"
   ├─ Prepares email data:
   │  ├─ Student email
   │  ├─ Subject info
   │  ├─ All exam results
   │  ├─ Average percentage
   │  └─ Custom message
   │
   ├─ POST /api/email/send (Next.js route)
   │  └─ Calls: POST backend:/email/send-grade-report
   │     ├─ Validates student exists
   │     ├─ Checks student has email
   │     ├─ Builds HTML email template
   │     └─ Sends via Resend API
   │
   ├─ Updates status: "sent" or "error"
   └─ Shows toast notification

EMAIL TEMPLATE INCLUDES:
   ├─ Greeting with student name
   ├─ Subject code and name
   ├─ Table with all exam results:
   │  ├─ Exam name
   │  ├─ Score (X/MAX)
   │  ├─ Percentage
   │  ├─ Grade
   │  └─ Status (Passed/Failed)
   ├─ Average grade
   ├─ Custom message (if provided)
   └─ Footer: "From PhotoSync"

⚠️  ISSUE: Email may send silently if RESEND_API_KEY not configured
    Without key, system returns success: true, but email never sent
```

---

## 8. Complete Data Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                 DATABASE SCHEMA FLOW                           │
└────────────────────────────────────────────────────────────────┘

users
├─ id (UUID)
├─ email (unique)
└─ password_hash

students
├─ id (UUID)
├─ user_id (FK → users)
├─ student_id (unique string)
├─ first_name
├─ last_name
├─ email
├─ course
└─ year_level

subjects
├─ id (UUID)
├─ user_id (FK → users)
├─ code
├─ name
└─ units

exams
├─ id (UUID)
├─ subject_id (FK → subjects)
├─ user_id (FK → users)
├─ name
├─ total_items
└─ points_per_item

exam_results
├─ id (UUID)
├─ student_id (FK → students)
├─ exam_id (FK → exams)
├─ user_id (FK → users)
├─ correct_answers
├─ total_score
├─ percentage
├─ grade
├─ grade_point
├─ remarks
└─ scanned_image_url

student_subjects
├─ id (UUID)
├─ student_id (FK → students)
├─ subject_id (FK → subjects)
└─ year_level

scoring_rules
├─ id (UUID)
├─ subject_id (FK → subjects)
├─ user_id (FK → users)
├─ min_score
└─ letter_grade
```

---

## 9. API Endpoints Summary

### Authentication ⚠️ (UNUSED - Uses Supabase instead)
- `POST /auth/signup` - Create account (unused in frontend)
- `POST /auth/login` - Login (unused in frontend)
- `GET /auth/me` - Current user (unused in frontend)

### Results & Grading ✅ (USED)
- `POST /results/` - Create exam result (from scanner)
- `GET /results/` - Get all results
- `GET /results/?student_id=...` - Get student results
- `GET /gpa/` - Calculate GPA for current user
- `GET /gpa/?student_id=...` - Get student GPA

### Email ✅ (USED)
- `POST /email/send-grade-report` - Send result email

### Scanner ✅ (USED)
- `POST /scanner/scan` - Detect check marks via Roboflow

### Other Controllers (CRUD)
- Students, Subjects, Exams, StudentSubjects, ScoringRules

---

## 10. Process Verification Checklist

### Authentication
- [ ] User can sign up with Supabase
- [ ] User can login with Supabase
- [ ] User session persists across page reloads
- [ ] Logout clears session
- [ ] Unauthenticated users redirected to login

### Dashboard
- [ ] Dashboard stats load and display correctly
- [ ] Quick action links work
- [ ] Page loads within 2 seconds

### Student Management
- [ ] Can view list of students
- [ ] Can search students
- [ ] Can add new student
- [ ] Can edit student
- [ ] Can delete student
- [ ] Student validation works (no empty fields)

### Subject & Exam Management
- [ ] Can create subjects
- [ ] Can create exams for subjects
- [ ] Exam points calculated correctly (total_items × points_per_item)

### Scanner
- [ ] Can select student
- [ ] Can select exam
- [ ] Can upload image
- [ ] Image preview displays
- [ ] Automatic detection works (or manual fallback)
- [ ] Result displays score, percentage, grade
- [ ] Can save result

### Grades & GPA
- [ ] Grades display in table
- [ ] GPA calculated correctly
- [ ] Grade scale follows MSU standard
- [ ] Can view student-specific grades

### Email
- [ ] Can select subject
- [ ] Can select students
- [ ] Can compose custom message
- [ ] Email sends (if API key configured)
- [ ] Email status shows correctly

### Network Access
- [ ] Can access dashboard from different device on same network
- [ ] All API calls work from network IP address
- [ ] No CORS errors

---

## 11. Known Issues in Flow

1. **Authentication Mismatch**: Frontend uses Supabase, Backend uses JWT
   - Impact: Backend auth endpoints unused
   - Fix: Choose one system

2. **API Endpoint Configuration**: Hardcoded to `/api/` routes
   - Impact: Won't work on network without proper configuration
   - Fix: Use NEXT_PUBLIC_API_URL environment variable

3. **Missing Environment Variables**: No .env files configured
   - Impact: App won't run
   - Fix: Create .env files with required credentials

4. **Scanner Dependency**: Requires Roboflow API configuration
   - Impact: Scanner may fail without API key
   - Fix: Configure Roboflow or use manual input

5. **Email Silent Failure**: Email sends without error if RESEND_API_KEY missing
   - Impact: User thinks email sent but it didn't
   - Fix: Add warning UI or return error status

---

## Next Steps

1. ✅ Verify each flow step above
2. ✅ Test authentication
3. ✅ Test student management
4. ✅ Test scanner
5. ✅ Test GPA calculation
6. ✅ Test email distribution
7. ✅ Test from network device
8. ✅ Verify environment variables are set

See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for configuration guide.
See [BUG_REPORT.md](BUG_REPORT.md) for detailed issues.
