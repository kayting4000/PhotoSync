# PhotoSync — Milestone 2 Submission Guide

**Course:** CCC151 | **Project:** PhotoSync — Test Paper Scanner & Grade Management
**Repository:** https://github.com/kayting4000/EduScan  
**Developer:** Habibun-najal K. Kayting

---

## ✅ Milestone 2 Checklist

| Requirement | Status | Details |
|-------------|--------|---------|
| Framework: FastAPI | ✅ Done | `backend/main.py` |
| MVC Architecture | ✅ Done | `models/`, `schemas/`, `controllers/` |
| Models (data schemas) | ✅ Done | `backend/models/` |
| Views / Schemas (Pydantic) | ✅ Done | `backend/schemas/` |
| Controllers (Routes) | ✅ Done | `backend/controllers/` |
| Full CRUD | ✅ Done | Students, Subjects, Exams, Results |
| Input validation | ✅ Done | Pydantic v2 on all endpoints |
| Error handling | ✅ Done | HTTPException on all routes |
| Database connection | ✅ Done | Supabase (PostgreSQL) via REST |
| Swagger UI `/docs` | ✅ Done | http://localhost:8000/docs |
| README with setup guide | ✅ Done | `backend/README.md` |
| Test script | ✅ Done | `backend/test_api.py` |

---

## 🏗 Architecture Overview

This project follows a strict **MVC (Model-View-Controller)** pattern:

```
backend/
│
├── main.py               ← Entry point, registers all routers
├── database.py           ← Supabase connection config (DB layer)
├── requirements.txt      ← All Python dependencies
├── test_api.py           ← Endpoint verification script
├── .env                  ← Credentials (not committed to Git)
│
├── models/               ← M: Data structure / table definitions
│   ├── student.py        ← students table schema
│   ├── subject.py        ← subjects table schema
│   ├── exam.py           ← exams table schema
│   └── exam_result.py    ← exam_results table schema
│
├── schemas/              ← V: Pydantic request/response validation
│   ├── auth.py           ← AuthLogin, AuthSignup
│   ├── student.py        ← StudentCreate, StudentUpdate
│   ├── subject.py        ← SubjectCreate, SubjectUpdate
│   ├── exam.py           ← ExamCreate
│   └── exam_result.py    ← ExamResultCreate
│
└── controllers/          ← C: Route handlers (business logic)
    ├── auth.py           ← POST /auth/signup, /auth/login
    ├── students.py       ← GET/POST/PUT/DELETE /students/
    ├── subjects.py       ← GET/POST/PUT/DELETE /subjects/
    ├── exams.py          ← GET/POST/DELETE /exams/
    ├── results.py        ← GET/POST/DELETE /results/
    ├── dashboard.py      ← GET /dashboard/
    └── grades.py         ← GET /gpa/
```

### How MVC maps to the code

| MVC Layer | Folder | Responsibility |
|-----------|--------|----------------|
| **Model** | `models/` | Defines table names and column structure for each entity |
| **View** | `schemas/` | Pydantic models that validate incoming requests and shape outgoing responses |
| **Controller** | `controllers/` | FastAPI `APIRouter` — handles HTTP requests, calls the DB, returns responses |

---

## 🚀 How to Set Up and Run

### Prerequisites
- Python 3.10+
- Git

---

### Step 1 — Clone the repository

```bash
git clone https://github.com/kayting4000/EduScan.git
cd EduScan/backend
```

---

### Step 2 — Create a virtual environment

```bash
python -m venv venv
```

Activate it:

**Windows:**
```bash
venv\Scripts\activate
```

**macOS / Linux:**
```bash
source venv/bin/activate
```

> You should see `(venv)` at the start of your terminal prompt.

---

### Step 3 — Install dependencies

```bash
pip install -r requirements.txt
```

**What gets installed (`requirements.txt`):**

```
fastapi           ← Web framework
uvicorn[standard] ← ASGI server
python-dotenv     ← Loads .env file
httpx             ← Async HTTP client for Supabase REST
pydantic[email]   ← Data validation (Views/Schemas)
python-multipart  ← Form data support
```

---

### Step 4 — Configure environment variables

Create a `.env` file inside the `backend/` folder:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

> Get these from: **Supabase Dashboard → Project Settings → API**

---

### Step 5 — Run the server

```bash
python -m uvicorn main:app --reload
```

> ⚠️ Use `python -m uvicorn` instead of just `uvicorn` if you get a "not recognized" error.

**Expected output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process using WatchFiles
```

---

### Step 6 — Open Swagger UI

Go to: **http://localhost:8000/docs**

You will see all endpoints grouped by tag, with the ability to test them directly in the browser.

![Swagger UI shows: Auth, Students, Subjects, Exams, Results, Dashboard, Grades]

---

## 📡 API Endpoints (Full CRUD)

### 🔐 Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/signup` | Register a new user |
| `POST` | `/auth/login` | Login — returns access token |

### 👥 Students *(Full CRUD)*
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/students/` | List all students |
| `POST` | `/students/` | Create a student |
| `PUT` | `/students/{id}` | Update a student |
| `DELETE` | `/students/{id}` | Delete a student |

### 📚 Subjects *(Full CRUD)*
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/subjects/` | List all subjects |
| `POST` | `/subjects/` | Create a subject |
| `PUT` | `/subjects/{id}` | Update a subject |
| `DELETE` | `/subjects/{id}` | Delete a subject |

### 📝 Exams *(CRD)*
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/exams/` | List all exams (filter: `?subject_id=`) |
| `POST` | `/exams/` | Create an exam |
| `DELETE` | `/exams/{id}` | Delete an exam |

### 📊 Results *(CRD)*
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/results/` | List results (filter: `?student_id=` or `?exam_id=`) |
| `POST` | `/results/` | Submit an exam result |
| `DELETE` | `/results/{id}` | Delete a result |

### 📈 Dashboard & Grades
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/dashboard/` | Total counts (students, subjects, exams, results) |
| `GET` | `/gpa/` | GPA calculation (filter: `?student_id=`) |
| `GET` | `/` | Health check |

---

## 🧪 Test Script

The test script verifies all endpoints are functional by running a full **Create → Read → Update → Delete** cycle.

### Run the tests

> ⚠️ Make sure the server is running first (`python -m uvicorn main:app --reload`)

Open a **second terminal**, then:

```bash
cd EduScan/backend
python test_api.py
```

### Expected output

```
=== PhotoSync API Tests ===

[Health]
  ✓ GET / [200]

[Students]
  ✓ POST /students/ [200]
  ✓ GET  /students/ [200]
  ✓ PUT  /students/{id} [200]

[Subjects]
  ✓ POST /subjects/ [200]
  ✓ GET  /subjects/ [200]
  ✓ PUT  /subjects/{id} [200]

[Exams]
  ✓ POST /exams/ [200]
  ✓ GET  /exams/ [200]

[Results]
  ✓ POST /results/ [200]
  ✓ GET  /results/ [200]

[Dashboard & GPA]
  ✓ GET /dashboard/ [200]
  ✓ GET /gpa/ [200]

[Cleanup]
  ✓ DELETE /results/{id} [200]
  ✓ DELETE /exams/{id} [200]
  ✓ DELETE /subjects/{id} [200]
  ✓ DELETE /students/{id} [200]

=== Done ===
```

---

## 🔍 Input Validation & Error Handling

All endpoints use **Pydantic v2** for automatic input validation.

**Example — creating a student with missing fields:**
```http
POST /students/
{
  "first_name": "Jane"
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "detail": [
    { "loc": ["body", "student_id"], "msg": "Field required", "type": "missing" },
    { "loc": ["body", "last_name"],  "msg": "Field required", "type": "missing" },
    { "loc": ["body", "course"],     "msg": "Field required", "type": "missing" }
  ]
}
```

**Example — invalid login:**
```http
POST /auth/login
{ "email": "wrong@email.com", "password": "wrongpass" }
```

**Response (401 Unauthorized):**
```json
{ "detail": "Invalid credentials" }
```

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Framework | FastAPI | API routing and docs |
| Language | Python 3.10+ | Backend logic |
| Validation | Pydantic v2 | Request/response schemas |
| HTTP Client | httpx (async) | Async calls to Supabase |
| Database | Supabase (PostgreSQL) | Data storage |
| Server | Uvicorn | ASGI server |

---

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| `'uvicorn' is not recognized` | Run `python -m uvicorn main:app --reload` |
| `ModuleNotFoundError` | Activate venv and run `pip install -r requirements.txt` |
| `401 Unauthorized` on all requests | Check `SUPABASE_KEY` in your `.env` file |
| `.env` not loading | Make sure `.env` is inside the `backend/` folder |
| Port already in use | Run on a different port: `python -m uvicorn main:app --reload --port 8001` |

---

*PhotoSync — Built with FastAPI, Pydantic, and Supabase*
