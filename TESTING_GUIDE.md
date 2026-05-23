# Testing Guide for EduScan

Complete testing checklist and instructions to validate all features and fix any remaining issues.

---

## Quick Start: Run Tests Locally

### Prerequisites
- Python 3.9+ installed
- Node.js 18+ and pnpm installed
- All environment variables configured (.env files created)

### Step 1: Start Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate    # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

Expected output:
```
Uvicorn running on http://0.0.0.0:8000
```

Verify: Open http://localhost:8000/docs in browser (FastAPI Swagger docs)

### Step 2: Start Frontend

In a new terminal:

```bash
pnpm install
pnpm dev
```

Expected output:
```
▲ Next.js 15.x
- Local:   http://localhost:3000
```

Verify: Open http://localhost:3000 in browser

---

## Part 1: Automated Testing

### Unit Tests

**Backend Tests** (Python):

```bash
cd backend
pytest tests/ -v
```

Current status: ❌ No tests present - Add pytest tests for:
- Authentication (signup, login, token validation)
- Grade calculation and GPA logic
- Email formatting
- Scanner image processing

**Frontend Tests** (JavaScript):

```bash
pnpm test
```

Current status: ❌ No tests configured - Add Jest tests for:
- Component rendering
- API calls
- State management
- Error handling

### Running Backend Test API

```bash
python backend/test_api.py
```

This script tests all API endpoints with sample data.

---

## Part 2: Manual Testing Checklist

### 1. Authentication Testing ✅

**Test: Sign Up**
```
1. Navigate to http://localhost:3000/auth/sign-up
2. Enter: 
   - Email: test@example.com
   - Password: Test123!@#
3. Verify:
   - Form validates (password strength shown)
   - Redirects to /auth/sign-up-success
   - Toast: "Account created successfully"
   - Then redirects to /dashboard
```

**Test: Login**
```
1. Navigate to http://localhost:3000/auth/login
2. Enter existing credentials
3. Verify:
   - Redirects to /dashboard
   - User info displayed in navbar
   - Session persists after refresh
```

**Test: Logout**
```
1. In dashboard, click user menu (top right)
2. Click "Sign Out"
3. Verify:
   - Redirects to /auth/login
   - Session cleared
   - Cannot access /dashboard without login
```

**Test: Session Persistence**
```
1. Login
2. Hard refresh page (Ctrl+F5)
3. Verify:
   - Still logged in
   - Session restored
   - No redirect to login
```

---

### 2. Dashboard Testing ✅

**Test: Dashboard Loads**
```
1. Login successfully
2. Navigate to /dashboard
3. Verify:
   - "Dashboard" heading appears
   - 4 stat cards load:
     - Total Students: Shows number
     - Subjects: Shows number
     - Exams Created: Shows number
     - Results Recorded: Shows number
   - Quick action cards display
   - All navigation links work
```

**Test: Stats Query Performance**
```
1. Open DevTools → Network tab
2. Load dashboard
3. Verify:
   - Dashboard loads in < 2 seconds
   - Only 2-3 database queries made
   - No N+1 queries
```

---

### 3. Student Management Testing ✅

**Test: View Students**
```
1. Click "Students" in nav
2. Navigate to /dashboard/students
3. Verify:
   - Student table displays
   - Columns: Student ID, Name, Email, Course, Year
   - Can scroll through list
```

**Test: Add Student**
```
1. Click "Add Student" button
2. Fill form:
   - Student ID: STU-001
   - First Name: John
   - Last Name: Doe
   - Email: john@example.com
   - Course: BS Information Technology
   - Year Level: 1
3. Click "Save"
4. Verify:
   - Toast: "Student added"
   - New student appears in table
   - Form clears
```

**Test: Search Students**
```
1. In students table, type in search box
2. Search by:
   - Student ID: "STU-001" → Filters correctly
   - Name: "John" → Shows John Doe
   - Course: "IT" → Shows IT students
3. Verify: Table updates in real-time
```

**Test: Edit Student**
```
1. Click edit icon on student row
2. Change: Last Name from "Doe" to "Smith"
3. Click "Save"
4. Verify:
   - Toast: "Student updated"
   - Table shows "John Smith"
```

**Test: Delete Student**
```
1. Click delete icon on student row
2. Confirm deletion dialog
3. Click "Delete"
4. Verify:
   - Toast: "Student deleted"
   - Student removed from table
   - No data error
```

---

### 4. Subject & Exam Management Testing ✅

**Test: Add Subject**
```
1. Navigate to /dashboard/subjects
2. Click "Add Subject"
3. Fill:
   - Subject Code: CS101
   - Subject Name: Introduction to Programming
   - Units: 3
4. Click "Save"
5. Verify:
   - Subject appears in list
   - Can add exams to it
```

**Test: Add Exam**
```
1. Under a subject, click "Add Exam"
2. Fill:
   - Exam Name: Midterm Exam
   - Total Items: 50
   - Points per Item: 2
3. Click "Save"
4. Verify:
   - Exam appears under subject
   - Max Score calculated: 50 × 2 = 100
```

---

### 5. Scanner Testing 🎯 (CRITICAL)

**Test: Scanner Component Loads**
```
1. Navigate to /dashboard/scanner
2. Verify elements display:
   - Student dropdown (populated with students)
   - Exam dropdown (populated with exams)
   - Image upload area
   - Manual score input
   - "Scan Test Paper" button
```

**Test: Image Upload**
```
1. Select student and exam
2. Click upload area or drag image
3. Choose image file (JPEG/PNG)
4. Verify:
   - Image preview displays
   - File size < 10MB
   - Image dimensions visible
```

**Test: Automatic Detection**
```
1. Upload image of test paper with check marks
2. Click "Scan Test Paper"
3. System should:
   - Process image
   - Detect check marks
   - Show: Check Marks: X
   - Calculate Score: X
   - Calculate Percentage: X%
   - Assign Grade: [1.0-5.0]
   - Show Status: Passed/Failed
4. Verify results are reasonable for the image
```

**Test: Manual Input (Fallback)**
```
1. If automatic detection doesn't work:
2. Enter manual score: 45
3. Click "Calculate"
4. Verify:
   - Percentage calculated correctly
   - Grade assigned correctly
   - Can save result
```

**Test: Save Result**
```
1. After getting scan result
2. Click "Save Result"
3. Verify:
   - Toast: "Grade saved successfully"
   - Result appears in /dashboard/grades
   - Exam result created in database
```

⚠️ **Expected Issue**: Scanner may fail if:
- ROBOFLOW_API_KEY not configured
- Roboflow workflow not set up
- Image format not supported

→ Use manual input as fallback

---

### 6. Grades & GPA Testing ✅

**Test: View Grades**
```
1. Navigate to /dashboard/grades
2. Verify:
   - All exam results display
   - Columns: Student, Subject, Exam, Score, %, Grade, Status
   - Results sorted by date (newest first)
```

**Test: GPA Calculation**
```
1. With multiple exam results entered:
2. Check GPA calculation displays:
   - Current GPA (e.g., 2.15)
   - Total Units (e.g., 24)
   - Subjects counted (e.g., 8)
   - Interpretation (e.g., "Good")
3. Verify calculation:
   - GPA = Σ(grade_point × units) / Σ(units)
   - Example: (1.0×3 + 1.5×3 + 2.0×3) / 9 = 1.5
```

**Test: Grade Scale**
```
Verify grade assignments:
   - 96-100% → 1.0 (Excellent)
   - 92-95% → 1.25
   - 88-91% → 1.5
   - 84-87% → 1.75
   - 80-83% → 2.0
   - 76-79% → 2.25
   - 72-75% → 2.5
   - 68-71% → 2.75
   - 60-67% → 3.0 (Passing)
   - <60% → 5.0 (Failed)
```

---

### 7. Email Testing ✅

**Test: Email Component Loads**
```
1. Navigate to /dashboard/email
2. Verify:
   - Subject dropdown loads with subjects
   - Student list filters correctly
   - Custom message text area available
```

**Test: Student Filtering**
```
1. Select a subject from dropdown
2. Verify:
   - Only shows students with results in that subject
   - Displays: Name, Average %, Grade
   - Shows which exams they took
```

**Test: Bulk Selection**
```
1. Check "Select All" checkbox
2. Verify:
   - All students get checked
3. Click again
4. Verify:
   - All students uncheck
5. Manually check some
6. Verify:
   - Can select subset
```

**Test: Send Email**
```
1. Select students
2. Optional: Add custom message
3. Click "Send Emails"
4. Verify for each student:
   - Status changes: Pending → Sending → Sent ✓
   - Or: Pending → Sending → Error ✗
```

**Test: Email Content** (if RESEND_API_KEY configured)
```
1. Check sent emails contain:
   - Student name
   - Subject code and name
   - Table with exam results:
     - Exam name
     - Score (X/MAX)
     - Percentage
     - Grade
     - Status
   - Custom message (if provided)
   - Professional styling
```

⚠️ **Expected**: Without RESEND_API_KEY, email returns "simulated" message

---

## Part 3: Network Testing (Cross-Device)

### Test from Same Network

**Setup**
```
1. Get your server IP:
   - Windows: ipconfig → IPv4 Address
   - macOS/Linux: ifconfig or hostname -I
   
2. Example: 192.168.1.100

3. On client device, open browser:
   http://192.168.1.100:3000
```

**Test: Frontend Loads**
```
1. Navigate to http://192.168.1.100:3000
2. Verify:
   - Landing page loads
   - Can access /auth/login
   - Can access /auth/sign-up
   - No CORS errors in console
```

**Test: Authentication**
```
1. Sign up or login
2. Verify:
   - No authentication errors
   - Redirects to dashboard
   - Session works
```

**Test: All Features Work**
```
1. Test each feature from network IP:
   - Dashboard loads
   - Student management works
   - Subject/Exam management works
   - Scanner works
   - Grades display
   - Email works
2. Verify:
   - No API errors
   - No 404 errors
   - No timeouts
   - All data loads
```

**Check Console for Errors**
```
1. Open DevTools (F12) → Console
2. Look for:
   - CORS errors → Fix API endpoint configuration
   - 404 errors → Verify API URL
   - Network timeouts → Check backend running
   - Type errors → Report bug
```

---

## Part 4: Performance Testing

### Load Times

**Test: Dashboard Load Time**
```
1. Open DevTools → Network tab
2. Load dashboard
3. Verify:
   - Metrics:
     - Largest Contentful Paint (LCP) < 2.5s
     - First Input Delay (FID) < 100ms
     - Cumulative Layout Shift (CLS) < 0.1
   - No loading spinners after 3 seconds
   - Smooth interactions
```

**Test: API Response Times**
```
1. Open DevTools → Network tab
2. Test endpoints:
   - GET /students → < 500ms
   - POST /results → < 1000ms
   - GET /gpa → < 500ms
3. Verify no slow queries
```

**Test: Image Upload Time**
```
1. Upload test paper image
2. Monitor time to:
   - Image preview: < 1s
   - Detection complete: < 5s
3. Verify progress indicator
```

---

## Part 5: Security Testing

### Input Validation

**Test: Email Validation**
```
1. Try to sign up with invalid email:
   - "notanemail" → Error shown
   - "test@" → Error shown
   - "test@example.com" → Accepted
2. Verify: Error messages clear
```

**Test: Password Validation**
```
1. Try weak passwords:
   - "123" → Rejected (too short)
   - "password" → Rejected (no special char)
   - "Test123!@#" → Accepted
2. Verify: Requirements shown
```

**Test: Student Data Validation**
```
1. Try to add student with missing fields
2. Verify: Form shows validation errors
3. Verify: Cannot submit invalid form
```

### SQL Injection Prevention

**Test: Malicious Input**
```
1. Try to search for student with:
   - "'; DROP TABLE students;--"
   - Verify: Treated as literal string
   - Verify: No SQL error displayed
   - Verify: Data remains intact
```

### Authentication Security

**Test: JWT Token**
```
1. Login successfully
2. Open DevTools → Storage → localStorage
3. Verify:
   - Auth token stored
   - Token is JWT format (xxx.yyy.zzz)
4. Never send token in URL or plain text
```

**Test: Session Timeout**
```
1. Login
2. Close browser
3. Clear cache
4. Open application
5. Verify:
   - Must login again
   - Previous session invalid
```

---

## Part 6: Browser Compatibility

Test in multiple browsers:

| Browser | Version | Status |
|---------|---------|--------|
| Chrome | Latest | ✓ Test |
| Firefox | Latest | ✓ Test |
| Safari | Latest | ✓ Test |
| Edge | Latest | ✓ Test |

### Test Checklist for Each Browser

```
[ ] Application loads
[ ] All components render
[ ] Forms work correctly
[ ] Navigation works
[ ] No console errors
[ ] Styles look correct
[ ] Images display
[ ] Responsive design works
```

---

## Part 7: Mobile Responsiveness

**Test: Mobile View**
```
1. Open DevTools → Device Toolbar
2. Test on:
   - iPhone 12 (390×844)
   - iPhone SE (375×667)
   - Android device (360×800)
3. Verify:
   - Layout responsive
   - Text readable
   - Buttons clickable
   - Forms usable
   - Navigation works
```

**Test: Tablet View**
```
1. Test on iPad (768×1024)
2. Verify:
   - Grid layouts work
   - Tables scrollable
   - Modals fit screen
```

---

## Part 8: Error Handling

### Test Error Scenarios

**Test: Network Error**
```
1. Turn off wifi/network
2. Try to load dashboard
3. Verify:
   - Clear error message shown
   - Not just blank page
   - Suggestion to reconnect
```

**Test: Backend Down**
```
1. Stop backend server
2. Try API call from frontend
3. Verify:
   - Error message shown
   - User knows what happened
   - Can retry when backend back online
```

**Test: Invalid Student ID**
```
1. Try to edit non-existent student
2. Verify:
   - Error message shown
   - Not internal server error
```

**Test: Missing Env Variables**
```
1. Unset ROBOFLOW_API_KEY
2. Try to scan
3. Verify:
   - Clear error: "Roboflow not configured"
   - Fallback to manual input works
```

---

## Part 9: Database Integrity

**Test: Data Consistency**
```
1. Add student
2. Add exam
3. Create result for student in exam
4. Verify:
   - Student links correctly
   - Exam links correctly
   - Result shows in grades
   - GPA calculation correct
```

**Test: Referential Integrity**
```
1. Delete exam
2. Verify:
   - Results associated with exam handled
   - No orphaned records
   - GPA recalculates
```

**Test: Duplicate Prevention**
```
1. Try to add student with same ID
2. Verify:
   - Error shown
   - Duplicate not created
```

---

## Final Validation Checklist

### Before Release ✅

- [ ] All authentication flows work
- [ ] Dashboard loads and displays stats
- [ ] Student management complete (add/edit/delete)
- [ ] Subject & exam management works
- [ ] Scanner works (auto or manual)
- [ ] Grades calculate correctly
- [ ] GPA calculation accurate
- [ ] Email distribution works
- [ ] Network access from other devices works
- [ ] No console errors
- [ ] No warning messages
- [ ] Performance acceptable
- [ ] Mobile responsive
- [ ] Cross-browser compatible
- [ ] Error messages clear
- [ ] Data validation working
- [ ] Security checks pass
- [ ] Database integrity verified
- [ ] Environment variables configured
- [ ] Documentation complete

---

## Test Results Summary

After completing all tests, fill in results:

```
Date: _______________
Tester: _______________
Backend Status: _______________
Frontend Status: _______________
Network Access: _______________
Performance: _______________
Browser: _______________

Issues Found:
1. _______________
2. _______________
3. _______________

Ready for Deployment: [ ] Yes [ ] No
```

---

## Troubleshooting During Testing

### Issue: CORS Error
**Error**: `Access to XMLHttpRequest blocked by CORS policy`

**Solution**:
1. Verify backend has CORS middleware
2. Check `NEXT_PUBLIC_API_URL` is correct
3. Ensure backend running on correct port
4. Check firewall allows connection

### Issue: Database Connection Error
**Error**: `DATABASE_URL is not set in .env`

**Solution**:
1. Create `.env` in backend/ folder
2. Add valid DATABASE_URL
3. Restart backend

### Issue: Scanner Not Working
**Error**: `Roboflow credentials not configured`

**Solution**:
1. Set ROBOFLOW_API_KEY
2. Or use manual input fallback
3. Check Roboflow API key valid

### Issue: Email Not Sending
**Message**: `Email simulated (RESEND_API_KEY not configured)`

**Solution**:
1. Set RESEND_API_KEY if you have account
2. Or use without email for development

### Test: Authentication Fails

**Error**: `Invalid credentials` or `User not found`

**Solution**:
1. Verify backend is running: `python backend/main.py`
2. Check user exists in database
3. Verify email/password are correct
4. Check backend logs for errors

---

## Next Steps After Testing

1. ✅ Fix any bugs found
2. ✅ Update documentation
3. ✅ Optimize performance
4. ✅ Prepare for deployment
5. ✅ Create user guide
6. ✅ Set up monitoring

See [BUG_REPORT.md](BUG_REPORT.md) for known issues.
See [PROCESS_FLOW.md](PROCESS_FLOW.md) for complete flow details.
See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for configuration.
