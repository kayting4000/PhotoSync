# 🎬 EduScan Video Presentation Script
**Total Duration: 5 minutes max**
**Team Breakdown:**
- 🟦 Team 1 — Introduction & App Flow: ~0:45
- 🟩 Team 2 — Frontend: ~2:00
- 🟥 Team 3 — Backend: ~2:00
- 🎬 Outro: ~0:15

---

## 🟦 TEAM 1 — Introduction & App Flow
**Duration: 0:00 – 0:45**

> *(Screen: App logo / splash screen or landing page)*

**[Speaker]:**
"Good day! We present **EduScan** — a smart test paper scanning and grade management system built for educators.

The problem we solve: teachers manually checking papers and computing grades is time-consuming and error-prone.

EduScan solves this with three core parts:
- A **Next.js web app** for full management on desktop
- A **Flutter mobile app** for scanning on the go
- A **FastAPI backend** with a PostgreSQL database powering everything

Here's the flow:"

> *(Screen: Simple flow diagram or navigate through the app)*

"A professor **logs in**, manages **students and subjects**, **scans a test paper** using the camera or uploads an image — the AI detects check marks automatically — the **grade is computed and saved**, and finally the student receives their **grade report via email**. Simple. Fast. Accurate."

---

## 🟩 TEAM 2 — Frontend
**Duration: 0:45 – 2:45**

### 0:45 – 1:00 | Authentication
> *(Screen: Login / Sign-up page)*

**[Speaker]:**
"The frontend is built with **Next.js 15**, **TypeScript**, **Tailwind CSS**, and **shadcn/ui** components.

Starting with authentication — users sign up or log in securely. The session is managed via JWT tokens stored in localStorage, and unauthenticated users are automatically redirected to login."

---

### 1:00 – 1:20 | Dashboard
> *(Screen: Dashboard page)*

"After login, the **dashboard** gives a quick overview — total students, subjects, exams created, and results recorded. Quick action buttons let you jump directly to adding a student, scanning a paper, or viewing grades."

---

### 1:20 – 1:40 | Student & Subject Management
> *(Screen: Students table → Add Student dialog → Subjects page)*

"The **Students page** lists all enrolled students with search and filter support. You can add, edit, or delete students in real time.

The **Subjects page** lets you create subjects with codes and units, then attach exams to each subject — defining total items and points per item."

---

### 1:40 – 2:15 | Scanner
> *(Screen: Scanner page — select student, subject, exam → upload image → result)*

"The **Test Paper Scanner** is the core feature. Select a student, subject, and exam, then upload a photo of the test paper sheet. The system sends it to **Roboflow AI**, which detects check marks and counts correct answers.

The score, percentage, and grade are computed instantly using the MSU grading scale. You can also override the score manually for essay-type exams. Once confirmed, the result is saved with one click."

---

### 2:15 – 2:45 | Grades & Email
> *(Screen: Grades page → GPA → Email page)*

"The **Grades page** shows all exam results per student — score, percentage, grade letter, and pass/fail status. The GPA is calculated automatically using a weighted average.

The **Email page** lets you select a subject, choose students, add a custom message, and send grade reports directly to their inbox — all in one action."

---

## 🟥 TEAM 3 — Backend
**Duration: 2:45 – 4:45**

### 2:45 – 3:05 | Stack & Structure
> *(Screen: VS Code showing backend folder / main.py / requirements.txt)*

**[Speaker]:**
"The backend is built with **FastAPI** and **Python**, connected to a **Neon PostgreSQL** database using **SQLAlchemy** as the ORM.

The project is structured into **models**, **schemas**, **controllers**, and a central **main.py** that registers all routes. It's deployed via **Railway** using the included Procfile."

---

### 3:05 – 3:25 | Authentication & Security
> *(Screen: auth.py controller or JWT code)*

"Authentication uses **JWT tokens**. On signup or login, the backend validates credentials, hashes passwords using bcrypt, and returns a signed access token. Every protected endpoint requires this token via a Bearer header — ensuring data is isolated per user."

---

### 3:25 – 3:50 | Core API Endpoints
> *(Screen: Swagger UI at /docs or controllers folder)*

"The API covers all major resources:
- `/students/` — full CRUD with user-scoped isolation
- `/subjects/` and `/exams/` — manage academic structure
- `/results/` — create and retrieve exam results
- `/gpa/` — calculates weighted GPA using the MSU scale
- `/scanner/scan` — receives a base64 image, forwards it to Roboflow, and returns the check mark count
- `/email/send-grade-report` — builds an HTML grade report and sends it via the Resend API"

---

### 3:50 – 4:20 | Scanner & GPA Logic
> *(Screen: scanner.py and grades.py or results controller)*

"Inside the scanner controller, the base64 image is sent to the **Roboflow Workflow API**. The response includes the number of detected check marks, which becomes the student's correct answer count.

The GPA controller loops through all exam results for a student, multiplies each grade point by the subject's unit credit, sums the weighted values, and divides by total units — following the standard Philippine university grading system."

---

### 4:20 – 4:45 | Database & Deployment
> *(Screen: scripts/001_create_tables.sql or Railway dashboard)*

"The database schema includes tables for users, students, subjects, exams, exam results, sections, and scoring rules — all with foreign key relationships and proper indexes.

Migrations are managed through SQL scripts in the `/scripts/` folder. The backend is deployed to **Railway** with auto-start via the Procfile, and environment variables are configured securely in the Railway dashboard."

---

## 🎬 OUTRO
**Duration: 4:45 – 5:00**

> *(Screen: App dashboard or team photo)*

**[All / Lead speaker]:**
"EduScan — built to save teachers time, reduce grading errors, and keep students informed.

Thank you!"

---

## 📋 Screen Recording Checklist

### Team 1
- [ ] App splash / logo screen
- [ ] Quick flow walkthrough (30 seconds max)

### Team 2
- [ ] Login and signup page
- [ ] Dashboard with real stats
- [ ] Students table + add dialog
- [ ] Subjects + exam creation
- [ ] Scanner — upload image → result
- [ ] Grades table + GPA
- [ ] Email send page

### Team 3
- [ ] Backend folder structure in editor
- [ ] FastAPI `/docs` Swagger UI
- [ ] Auth controller (JWT)
- [ ] Scanner controller code
- [ ] GPA calculation logic
- [ ] Database SQL schema or Railway dashboard

---

## 🕐 Timing Summary

| Team | Section | Time |
|------|---------|------|
| Team 1 | Intro + Flow | 0:00 – 0:45 |
| Team 2 | Frontend | 0:45 – 2:45 |
| Team 3 | Backend | 2:45 – 4:45 |
| All | Outro | 4:45 – 5:00 |
| **Total** | | **5:00** |
