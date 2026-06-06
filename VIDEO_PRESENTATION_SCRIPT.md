# 🎬 PhotoSync Video Presentation Script
**Total Duration: 5 minutes max**

---

## 🎥 SCREEN RECORDING GUIDE — Flow Demo
**Duration: 0:00 – 5:00**

> *Record your phone/emulator screen showing the entire app flow*

### 0:00 – 0:20 | Introduction
> *(Screen: App logo / splash screen)*

**Narrator:**
"Good day! We present **PhotoSync** — a smart test paper scanning and grade management system built for educators.

The problem we solve: teachers manually checking papers and computing grades is time-consuming and error-prone. PhotoSync uses **AI-powered scanning** via Roboflow, automatic grade computation, and **Gmail SMTP** for sending grade reports directly to students."

---

### 0:20 – 1:00 | Login / Sign-up
> *(Screen: Login page on Flutter app)*

**Actions to record:**
1. Open the PhotoSync Flutter app
2. Type email and password
3. Tap **Sign In**

**Narrator:**
"Professors sign in securely. Authentication is powered by a **FastAPI backend** with **JWT tokens** and **bcrypt password hashing**. Every user's data is completely isolated."

---

### 1:00 – 1:30 | Dashboard Overview
> *(Screen: Dashboard page)*

**Actions to record:**
1. After login, the **Dashboard** appears
2. Show total students, subjects, exams counts
3. Show quick action buttons

**Narrator:**
"The **Dashboard** gives a quick overview. From here you can jump to any section."

---

### 1:30 – 2:00 | Students & Subjects
> *(Screen: Students list → Subject sections)*

**Actions to record:**
1. Tap **Students** from drawer menu
2. Show the list of students
3. Tap on a student to view their record
4. Go back and tap **Subjects**

**Narrator:**
"Manage your **students** and **subjects** with full CRUD. Each student belongs to a section. You can add exam scores, track attendance, and view performance."

---

### 2:00 – 3:00 | AI Scanner — The Core Feature
> *(Screen: Scanner screen)*

**Actions to record:**
1. Tap **Scanner** from drawer menu
2. Select a **student** from dropdown
3. Select a **semester**
4. Tap **Add Page** → choose **Gallery**
5. Select a test paper image *(have a sample ready)*
6. Tap **Scan Page**
7. Wait for scan results to show detected count

**Narrator:**
"The **AI Scanner** is the heart of PhotoSync. Select a student, choose the term, then add answer sheet pages from your gallery.

Tap **Scan** and the image is sent to **Roboflow AI**, which detects check marks and counts correct answers. The result is automatically saved as an exam grade."

---

### 3:00 – 3:30 | Grades & GPA
> *(Screen: Grades page)*

**Actions to record:**
1. Tap **Grades** from drawer menu
2. Show the **GPA summary** with average, highest, lowest
3. Scroll to show **All Exam Results**

**Narrator:**
"The **Grades page** shows all results with percentages and grade letters. **GPA is calculated automatically** using the MSU-TCTO grading scale."

---

### 3:30 – 4:15 | Send Grade Email
> *(Screen: Student Record → Send Email)*

**Actions to record:**
1. Go to **Students** from drawer
2. Tap a student that has exam results
3. Tap the **green email icon** (top right)
4. Wait for: "✅ Grade sent to student@email.com"

**Narrator:**
"PhotoSync lets you send individual grade reports with one tap. Open any student's record, tap the green email button, and they receive a formatted HTML grade report via **Gmail SMTP**."

---

### 4:15 – 4:45 | Backend & Swagger API
> *(Screen: Browser showing http://localhost:8000/docs)*

**Actions to record:**
1. Open browser to `http://localhost:8000/docs`
2. Scroll through API endpoints

**Narrator:**
"The **FastAPI backend** powers everything. Swagger UI at `/docs` lets you test every endpoint. Database is **Neon PostgreSQL** via **SQLAlchemy**."

---

### 4:45 – 5:00 | Conclusion
> *(Screen: Back to app dashboard)*

**Narrator:**
"PhotoSync — built to save teachers time, eliminate grading errors, and keep students informed with instant grade reports via email. Thank you!"

---

## ⏱️ Timing Summary

| Section | Time |
|---------|------|
| 🎬 Introduction | 0:00 – 0:20 |
| 🔐 Login | 0:20 – 1:00 |
| 📊 Dashboard | 1:00 – 1:30 |
| 👨‍🎓 Students & Subjects | 1:30 – 2:00 |
| 🤖 AI Scanner | 2:00 – 3:00 |
| 📈 Grades & GPA | 3:00 – 3:30 |
| 📧 Send Email | 3:30 – 4:15 |
| ⚙️ Backend / Swagger | 4:15 – 4:45 |
| 🎯 Conclusion | 4:45 – 5:00 |
| **Total** | **5:00** |

---

## 📋 Recording Checklist

### Before:
- [ ] Backend running at `http://localhost:8000`
- [ ] Flutter app connected to backend
- [ ] Sample student with exam results created
- [ ] Sample answer sheet image in gallery
- [ ] Close other apps

### During:
- [ ] Speak clearly at steady pace
- [ ] Pause 2 seconds between actions
- [ ] Wait for scan to complete before narrating
- [ ] Wait for email success snackbar

### After:
- [ ] Trim video to 5:00 or less
- [ ] Export as MP4