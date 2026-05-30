#!/usr/bin/env python3
"""
⚡ QUICK REFERENCE - Send Grades to Student

This is a quick copy-paste guide for the most common task.
"""

# ============================================================================
# STEP 1: GET YOUR TOKEN
# ============================================================================
"""
1. Open: http://localhost:3000
2. Sign in
3. Press: F12 (Open DevTools)
4. Go to: Application tab
5. Left sidebar: Local Storage → http://localhost:3000
6. Find: "access_token"
7. Copy the value (looks like: eyJhbGc...)
"""

# ============================================================================
# STEP 2: SEND GRADES
# ============================================================================
"""
Open terminal/command prompt:

  cd backend
  python send_student_grades.py --email kayting4k@gmail.com --token YOUR_TOKEN_HERE

Replace YOUR_TOKEN_HERE with the token you copied above.
"""

# ============================================================================
# STEP 3: LOOK FOR SUCCESS
# ============================================================================
"""
You should see something like:

╔═════════════════════════════════════════════════════════╗
║         PhotoSync - Send Student Grades Script          ║
║                  2026-05-29 21:47                        ║
╚═════════════════════════════════════════════════════════╝

📧 Sending grades to: kayting4k@gmail.com
🔐 Using API: http://localhost:8000
------------------------------------------------------------
✅ Success!
   Student: kayting4k@gmail.com
   Emails sent: 2
   - MATH101: Grade report sent to kayting4k@gmail.com
   - ENG101: Grade report sent to kayting4k@gmail.com
------------------------------------------------------------
✅ All grades sent successfully!
"""

# ============================================================================
# TROUBLESHOOTING
# ============================================================================
"""
❌ "Student not found"
   → Check: Student exists with email kayting4k@gmail.com in Dashboard

❌ "No exam results found"
   → Check: Student has at least one recorded grade
   → Use Dashboard → Scanner to record grades

❌ "Email service not configured"
   → Get key from https://resend.com
   → Add to backend/.env: RESEND_API_KEY=re_your_key
   → Restart backend: uvicorn main:app --reload

❌ "Cannot connect to backend"
   → Start backend: cd backend && uvicorn main:app --reload
   → Wait for "Uvicorn running on http://0.0.0.0:8000"

❌ "Authentication token required"
   → Make sure token starts with "eyJ"
   → Copy full token, not just part of it
"""

# ============================================================================
# FULL WORKFLOW (First Time Setup)
# ============================================================================
"""
1. Start backend:
   cd backend
   uvicorn main:app --reload
   
2. Start frontend:
   npm run dev
   
3. Open http://localhost:3000 and sign in

4. Create student:
   Dashboard → Students → Add Student
   - Email: kayting4k@gmail.com
   - Other fields: any values
   Click Save

5. Create subject:
   Dashboard → Subjects → Add Subject
   - Code: MATH101
   - Name: Calculus I
   Click Save

6. Create exam:
   Click on subject → Add Exam
   - Name: Midterm
   - Total Items: 50
   - Points per Item: 2
   Click Save

7. Record grade:
   Dashboard → Scanner
   - Student: kayting4k@gmail.com
   - Exam: MATH101
   - Upload image or manually enter 45
   Click Save

8. Get token:
   F12 → Application → Local Storage
   Copy "access_token"

9. Send grades:
   cd backend
   python send_student_grades.py --email kayting4k@gmail.com --token TOKEN

Done! ✅
"""

# ============================================================================
# ADVANCED: CRON JOB (Linux/Mac)
# ============================================================================
"""
To send grades automatically every day at 8 AM:

crontab -e

Add this line:
0 8 * * * cd /path/to/backend && python send_student_grades.py --email kayting4k@gmail.com --token YOUR_TOKEN >> grade_emails.log 2>&1

Save and close (Ctrl+X then Y in nano, :wq in vim)

Check it's installed:
crontab -l
"""

# ============================================================================
# WINDOWS TASK SCHEDULER
# ============================================================================
"""
1. Open Task Scheduler
2. Create Basic Task
3. Name: "Send Daily Grades"
4. Trigger: Daily at 8:00 AM
5. Action: Start program
   - Program: C:\Python\python.exe
   - Arguments: C:\path\to\send_student_grades.py --email kayting4k@gmail.com --token TOKEN
   - Working directory: C:\path\to\backend
6. Create
"""

# ============================================================================
# API CALL (Using CURL)
# ============================================================================
"""
Directly call the API without the script:

curl -H "Authorization: Bearer YOUR_TOKEN" \\
     http://localhost:8000/email/send-grades-to-student/kayting4k@gmail.com

Should return:
{
  "success": true,
  "student_email": "kayting4k@gmail.com",
  "emails_sent": [...],
  "total": 2
}
"""

# ============================================================================
# WHAT STUDENT RECEIVES
# ============================================================================
"""
Beautiful HTML email from PhotoSync with:
- Greeting: "Dear John Doe,"
- Subject info: "MATH101 - Calculus I"
- Table with all exams:
  - Exam name
  - Score (e.g., 45/50)
  - Percentage (e.g., 90%)
  - Grade (e.g., 1.25)
  - Pass/Fail status
- Overall performance highlight (large, colorful)
"""

# ============================================================================
print(__doc__)
