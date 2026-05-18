# PhotoSync Backend — 5-Minute Swagger Demo Script

---

Good morning/afternoon, everyone. I'm going to show you PhotoSync — a grade management backend for MSU-Tawi-Tawi, built with FastAPI.

My entire presentation is this Swagger page. No PowerPoint. Everything I'm about to show is live and interactive.

---

Let me start with the health check. Scroll to the top — GET slash. I click Execute, and we get the app name, version, and status running. This confirms the server is live.

---

Now look at all these endpoint groups — Auth, Students, Subjects, Exams, Results, Dashboard, and Grades. Nineteen endpoints total, all auto-documented by FastAPI. Each one shows you exactly what data it expects and what it returns.

---

Let me walk through a full CRUD cycle on Students.

First, GET slash students. I click Execute — there's one student in the database. You can filter by course and year level using these query parameters.

Now POST — I click Try it out. I'll fill in student ID 2024 dash 00123, first name Juan, last name Dela Cruz, course BSCS, year level 2. Execute. Response 200 — here's the created student with a UUID and timestamp. Pydantic validated every field before it even hit the database.

PUT — I copy the ID, paste it in the path. Change year level to 3. Execute. Updated.

DELETE — same ID. Execute. Student deleted. Full CRUD in under a minute, all from this browser tab.

---

Now let me show you the most powerful feature — automatic grade assignment. Open POST slash results. I enter a student ID, exam ID, 40 correct answers out of 50, total score of 85, and percentage of 85. Execute.

Look at the response — grade is 1.75, grade point is 1.75, remarks Passed. I never typed those. The backend applied the MSU grading scale automatically. 85 percent maps to 1.75 on the official MSU scale. No spreadsheets, no manual lookups.

---

Now GPA. Open GET slash gpa. Enter a student ID. Execute. The response shows GPA of 1.625 across 8 units, interpreted as Very Good. The formula is sum of grade point times units, divided by total units. The backend does the weighted computation — you just provide the results, the system computes everything.

---

Here's the grading scale built into the code. 96 to 100 gets 1.0, 92 to 95 gets 1.25, down to 60 to 67 getting 3.0, and below 60 is 5.0 Failed. All ten levels of the MSU scale are implemented.

---

Dashboard — GET slash dashboard. Execute. Total students, total subjects, total exams, total results. One endpoint gives you the overview of your entire system.

---

And authentication — POST slash signup with email and password, POST slash login returns a JWT access token. Supabase Auth handles password hashing so we never store plain passwords.

---

To summarize — we built a FastAPI backend with strict MVC architecture. Models for database tables, schemas for Pydantic validation, controllers for business logic. Full CRUD on students, subjects, exams, and results. Automatic grade assignment using the MSU scale. Weighted GPA computation. And everything documented and testable right here in Swagger.

The repo is at github.com slash kayting4000 slash EduScan.

Thank you. I'm happy to demonstrate any endpoint up close.