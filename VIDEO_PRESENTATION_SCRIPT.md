# 🎬 PhotoSync Video Presentation Script
**Total Duration: 5 minutes max**

---

## 🎥 APP WALKTHROUGH — Sign In to Email
> *Record your phone/emulator screen showing the entire app flow*

### 0:00 – 0:30 | Introduction
> *(Screen: App logo / splash screen or start screen)*

**Narrator:**
"Good day! We present **PhotoSync** — a smart test paper scanning and grade management system built for educators.

The problem we solve: teachers manually checking papers and computing grades is time-consuming and error-prone. PhotoSync uses **AI-powered scanning** to detect check marks automatically, computes grades, and sends reports via **email**."

---

### 0:30 – 1:15 | Login
> *(Screen: Login page)*

**Actions to record:**
1. Open the PhotoSync Flutter app
2. Type email in the email field
3. Type password in the password field
4. Tap **Sign In**
5. *(If first time, show Sign Up first, then login)*

**Narrator:**
"Teachers sign in securely. Authentication is powered by the backend with **JWT tokens** to keep every user's data safe and isolated."

---

### 1:15 – 1:45 | Dashboard
> *(Screen: Dashboard page)*

**Actions to record:**
1. After login, the **Dashboard** loads
2. Scroll or swipe to show:
   - Total students
   - Subjects
   - Exams
   - Quick action buttons (Add Student, Scan, Grades)

**Narrator:**
"The **Dashboard** gives a quick overview of your data — total students, subjects, exams, and results. From here you can jump to any section."

---

### 1:45 – 2:15 | Students & Subjects
> *(Screen: Students list → Subject sections)*

**Actions to record:**
1. Open the drawer menu (hamburger icon)
2. Tap **Students**
3. Show the list of enrolled students
4. Tap on a student to view their full record
5. Go back, open drawer, tap **Subjects**
6. Show subjects list

**Narrator:**
"Manage your **students** and **subjects** easily. Each student has a complete record where you can add exam scores, track attendance, and view performance."

---

### 2:15 – 3:15 | AI Scanner
> *(Screen: Scanner screen)*

**Actions to record:**
1. Open drawer, tap **Scanner**
2. Select a **student** from the dropdown
3. Select a **semester** (Preliminary / Mid-Semester / Final)
4. Tap **Add Page** → choose **Gallery**
5. Pick a test paper image from your device
6. Wait for page thumbnail to appear
7. Tap **Scan Page**
8. Wait for AI to process — shows **check marks detected** count

**Narrator:**
"The **AI Scanner** is the core feature. Select a student and term, add an answer sheet from your gallery or camera, and tap Scan.

The image is sent to **Roboflow AI**, which detects check marks and counts correct answers. The result is automatically saved as an exam grade."

---

### 3:15 – 3:50 | Grades & GPA
> *(Screen: Grades page)*

**Actions to record:**
1. Open drawer, tap **Grades**
2. Show the **GPA summary card** with:
   - Cumulative GPA
   - Average percentage
   - Highest and lowest scores
3. Scroll down to **All Exam Results**
4. Point to the grade from the scan you just did

**Narrator:**
"The **Grades page** displays everything — GPA, average scores, and all exam results with percentages and grade letters. Grades are **calculated automatically** so teachers don't have to compute manually."

---

### 3:50 – 4:30 | Send Grade Email
> *(Screen: Student record → Send email)*

**Actions to record:**
1. Open drawer, tap **Students**
2. Tap on a student that has exam results
3. On their record screen, look at the **top-right corner**
4. Tap the **green email icon**
5. Wait for the snackbar: *"✅ Grade sent to [email]"*

**Narrator:**
"PhotoSync lets you send grade reports individually. Open any student's record, tap the **green email button**, and they instantly receive a formatted grade report via **Gmail SMTP** — right to their inbox."

---

### 4:30 – 5:00 | Conclusion
> *(Screen: Back to app dashboard or PhotoSync logo)*

**Narrator:**
"PhotoSync makes grading fast, accurate, and paperless. Teachers save time, students stay informed.

Thank you for watching!"

---

## ⏱️ Timing Summary

| Section | Time |
|---------|------|
| 🎬 Introduction | 0:00 – 0:30 |
| 🔐 Login | 0:30 – 1:15 |
| 📊 Dashboard | 1:15 – 1:45 |
| 👨‍🎓 Students & Subjects | 1:45 – 2:15 |
| 🤖 AI Scanner | 2:15 – 3:15 |
| 📈 Grades & GPA | 3:15 – 3:50 |
| 📧 Send Email | 3:50 – 4:30 |
| 🎯 Conclusion | 4:30 – 5:00 |
| **Total** | **5:00** |

---

## 📋 Recording Checklist

### Before recording:
- [ ] Backend running at `http://localhost:8000`
- [ ] Install APK on phone or open emulator
- [ ] Have a sample student with exam results already created
- [ ] Have a sample answer sheet image (with check marks) in your gallery
- [ ] Set phone to **Do Not Disturb** mode

### During recording:
- [ ] Speak clearly at steady pace
- [ ] Pause 2 seconds between each action
- [ ] Navigate slowly — don't rush through menus
- [ ] Wait for scan to finish before narrating result
- [ ] After email tap, wait for success snackbar

### After recording:
- [ ] Trim video to exactly 5:00 or less
- [ ] Add intro/title card if possible
- [ ] Export as MP4