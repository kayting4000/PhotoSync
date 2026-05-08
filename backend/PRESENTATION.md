# EduScan Backend — Presentation Guide
### Milestone 2 | FastAPI + Supabase + MVC

---

## Slide 1 — Title

**EduScan**
*Test Paper Scanner & Grade Management System*

- **Framework:** FastAPI (Python)
- **Database:** Supabase (PostgreSQL)
- **Architecture:** MVC (Model-View-Controller)
- **Team:** Habibun-najal Kayting · Hareeja Montenegro · Mohd Shaffiqh Anang
- **Repo:** https://github.com/kayting4000/EduScan

---

## Slide 2 — What is EduScan?

A backend system that lets teachers:

- 👥 Manage **students** and **subjects**
- 📝 Create and track **exams**
- 📊 Record **exam results** and auto-calculate **grades & GPA**
- 🔐 Authenticate users via **Supabase Auth**
- 📈 View **dashboard statistics** in real-time

---

## Slide 3 — Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | FastAPI |
| Language | Python 3.10+ |
| Validation | Pydantic v2 |
| HTTP Client | httpx (async) |
| Database | Supabase (PostgreSQL) |
| Server | Uvicorn |

---

## Slide 4 — MVC Architecture

```
backend/
├── models/       ← M: Table definitions (what data looks like in DB)
├── schemas/      ← V: Pydantic models (what data looks like in API)
├── controllers/  ← C: Route handlers (business logic)
├── database.py   ← Supabase connection config
└── main.py       ← Registers all routers
```

**Models** → define the database structure
**Schemas** → validate requests and shape responses
**Controllers** → handle the HTTP logic between them

---

## Slide 5 — Database Schema

```
students     → id, student_id, first_name, last_name, email, course, year_level
subjects     → id, code, name, units
exams        → id, subject_id, name, exam_type, total_items, points_per_item
exam_results → id, student_id, exam_id, correct_answers, total_score, percentage, grade
```

All tables hosted on **Supabase (PostgreSQL)** with Row Level Security enabled.

---

## Slide 6 — API Endpoints Overview

| Group | Endpoints |
|-------|-----------|
| Auth | POST `/auth/signup` · POST `/auth/login` |
| Students | GET · POST · PUT · DELETE `/students/` |
| Subjects | GET · POST · PUT · DELETE `/subjects/` |
| Exams | GET · POST · DELETE `/exams/` |
| Results | GET · POST · DELETE `/results/` |
| Dashboard | GET `/dashboard/` |
| Grades | GET `/gpa/` |

**Total: 19 endpoints** — all documented at `/docs`

---

## Slide 7 — Full CRUD: Students Example

**Create**
```json
POST /students/
{ "student_id": "2021-001", "first_name": "Juan", "last_name": "Dela Cruz",
  "course": "BSIT", "year_level": 2, "email": "juan@email.com" }
```

**Read**
```
GET /students/  → returns list of all students
```

**Update**
```json
PUT /students/{id}
{ "year_level": 3 }
```

**Delete**
```
DELETE /students/{id}  → { "message": "Student deleted" }
```

---

## Slide 8 — Input Validation & Error Handling

Pydantic automatically rejects bad requests:

```json
POST /students/  ← missing required fields

Response 422:
{
  "detail": [
    { "loc": ["body", "student_id"], "msg": "Field required" },
    { "loc": ["body", "course"],     "msg": "Field required" }
  ]
}
```

Wrong credentials:
```json
POST /auth/login  ← wrong password
Response 401: { "detail": "Invalid credentials" }
```

---

## Slide 9 — Auto Grade Calculation

When a result is submitted, grade is assigned automatically:

| Percentage | Grade |
|------------|-------|
| 90 – 100 | A+ |
| 85 – 89 | A |
| 80 – 84 | B+ |
| 75 – 79 | B |
| 70 – 74 | C+ |
| 65 – 69 | C |
| 60 – 64 | D |
| Below 60 | F |

GPA formula: `(average% / 100 × 3.0) + 1.0` → clamped between 1.0 – 4.0

---

## Slide 10 — Swagger UI (Live Demo)

FastAPI auto-generates interactive API docs at:

**http://localhost:8000/docs**

- Test every endpoint directly in the browser
- See request/response schemas
- No Postman needed

---

## Slide 11 — How to Run

```bash
# 1. Clone
git clone https://github.com/kayting4000/EduScan.git
cd EduScan/backend

# 2. Install
pip install -r requirements.txt

# 3. Add .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key

# 4. Run
python -m uvicorn main:app --reload
```

Open → http://localhost:8000/docs

---

## Slide 12 — Test Script

Verifies all endpoints with a full CRUD cycle:

```bash
python test_api.py
```

```
=== EduScan API Tests ===
  ✓ GET  /           [200]
  ✓ POST /students/  [200]
  ✓ GET  /students/  [200]
  ✓ PUT  /students/  [200]
  ✓ POST /subjects/  [200]
  ✓ POST /exams/     [200]
  ✓ POST /results/   [200]
  ✓ GET  /dashboard/ [200]
  ✓ GET  /gpa/       [200]
  ✓ DELETE ...       [200]
=== Done ===
```

---

## Slide 13 — Summary

| Requirement | Delivered |
|-------------|-----------|
| FastAPI framework | ✅ |
| MVC architecture | ✅ models / schemas / controllers |
| Full CRUD | ✅ Students, Subjects, Exams, Results |
| Input validation | ✅ Pydantic v2 |
| Error handling | ✅ HTTPException on all routes |
| Database connection | ✅ Supabase PostgreSQL |
| Swagger UI `/docs` | ✅ |
| README setup guide | ✅ backend/README.md |
| Test script | ✅ backend/test_api.py |

**GitHub:** https://github.com/kayting4000/EduScan
