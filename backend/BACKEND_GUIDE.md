# PhotoSync Backend — Complete Learning Guide

> This guide explains every part of the backend in simple terms.
> No prior backend experience needed.

---

## Table of Contents

1. [What is a Backend?](#1-what-is-a-backend)
2. [What is FastAPI?](#2-what-is-fastapi)
3. [What is MVC?](#3-what-is-mvc)
4. [Project Structure Explained](#4-project-structure-explained)
5. [database.py — Connecting to Supabase](#5-databasepy--connecting-to-supabase)
6. [Models — Defining Tables](#6-models--defining-tables)
7. [Schemas — Validating Data](#7-schemas--validating-data)
8. [Controllers — Handling Requests](#8-controllers--handling-requests)
9. [main.py — Putting It All Together](#9-mainpy--putting-it-all-together)
10. [How a Request Travels Through the Code](#10-how-a-request-travels-through-the-code)
11. [CRUD Explained](#11-crud-explained)
12. [Error Handling](#12-error-handling)
13. [MSU Grading Logic](#13-msu-grading-logic)
14. [GPA Computation](#14-gpa-computation)
15. [Authentication](#15-authentication)
16. [Swagger UI](#16-swagger-ui)
17. [test_api.py — Testing the API](#17-test_apipy--testing-the-api)
18. [Common Errors & Fixes](#18-common-errors--fixes)
19. [Glossary](#19-glossary)

---

## 1. What is a Backend?

A **backend** is the part of an application that runs on a server.
It handles data, logic, and communication with the database.

```
[ User / App ]  <-->  [ Backend API ]  <-->  [ Database ]
  Flutter/Web          FastAPI (us)          Supabase
```

The user never talks to the database directly.
They talk to the **API**, and the API talks to the database.

Think of it like a bank:
- You (customer) talk to the **teller** (API)
- The teller accesses the **vault** (database)
- You never touch the vault directly

---

## 2. What is FastAPI?

**FastAPI** is a Python framework for building APIs quickly.

Why we use it:
- Very fast and modern
- Automatically generates Swagger UI docs at `/docs`
- Built-in input validation via Pydantic
- Supports async (handles many requests at once)

A basic FastAPI app looks like this:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/hello")
def say_hello():
    return {"message": "Hello World"}
```

When you run this and visit `http://localhost:8000/hello`, you get:
```json
{ "message": "Hello World" }
```

That's it. FastAPI turns Python functions into API endpoints.

---

## 3. What is MVC?

**MVC = Model, View, Controller**

It is a way to organize your code so each part has one job.

| Layer | Folder | Job |
|-------|--------|-----|
| Model | `models/` | Defines what the database table looks like |
| View | `schemas/` | Defines what data comes in and goes out |
| Controller | `controllers/` | Handles the request and runs the logic |

### Analogy: A Restaurant

```
Customer (you)     →  places an order
Waiter             →  Controller  (takes order, brings food)
Menu               →  Schema/View (defines what you can order)
Kitchen            →  Model + DB  (prepares the actual food)
```

### Why separate them?

- Easier to find bugs (each file has one job)
- Easier to change one part without breaking others
- Cleaner, more readable code

---

## 4. Project Structure Explained

```
backend/
│
├── main.py          ← Starts the app, registers all routes
├── database.py      ← Supabase connection setup
├── requirements.txt ← List of Python packages needed
├── test_api.py      ← Script to test all endpoints
├── .env             ← Secret credentials (never commit this!)
│
├── models/          ← M in MVC
│   ├── student.py       defines TABLE = "students"
│   ├── subject.py       defines TABLE = "subjects"
│   ├── exam.py          defines TABLE = "exams"
│   └── exam_result.py   defines TABLE = "exam_results"
│
├── schemas/         ← V in MVC (Pydantic validation)
│   ├── auth.py          AuthLogin, AuthSignup
│   ├── student.py       StudentCreate, StudentUpdate
│   ├── subject.py       SubjectCreate, SubjectUpdate
│   ├── exam.py          ExamCreate
│   └── exam_result.py   ExamResultCreate
│
└── controllers/     ← C in MVC (route handlers)
    ├── auth.py          POST /auth/login, /auth/signup
    ├── students.py      GET/POST/PUT/DELETE /students/
    ├── subjects.py      GET/POST/PUT/DELETE /subjects/
    ├── exams.py         GET/POST/DELETE /exams/
    ├── results.py       GET/POST/DELETE /results/
    ├── grades.py        GET /gpa/
    └── dashboard.py     GET /dashboard/
```

---

## 5. database.py — Connecting to Supabase

```python
import httpx
import os
from dotenv import load_dotenv

load_dotenv()  # reads your .env file

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
```

### What is Supabase?

Supabase is a cloud database service.
It gives you a **PostgreSQL database** and a **REST API** to talk to it.

Instead of writing raw SQL like:
```sql
SELECT * FROM students;
```

We send an HTTP request like:
```
GET https://yourproject.supabase.co/rest/v1/students
```

### The Helper Functions

```python
def rest_url(table: str) -> str:
    return f"{SUPABASE_URL}/rest/v1/{table}"
```
This builds the URL for any table.
- `rest_url("students")` → `https://yourproject.supabase.co/rest/v1/students`
- `rest_url("exams")`    → `https://yourproject.supabase.co/rest/v1/exams`

```python
def get_headers(token: str = None):
    h = HEADERS.copy()
    if token:
        h["Authorization"] = f"Bearer {token}"
    return h
```
This adds your API key to every request so Supabase knows it's you.

### The .env File

```
SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Never hardcode credentials in your code.
Always use environment variables. This is a security best practice.

---

## 6. Models — Defining Tables

Models in this project are simple — they just define the table name.

```python
# models/student.py
"""
Student model — represents the 'students' table in Supabase.

Columns:
  id            uuid  PRIMARY KEY
  student_id    text  UNIQUE NOT NULL
  first_name    text  NOT NULL
  last_name     text  NOT NULL
  email         text
  course        text  NOT NULL
  year_level    int   DEFAULT 1
  created_at    timestamptz DEFAULT now()
"""

TABLE = "students"
```

### Why so simple?

Because Supabase manages the actual database schema.
We don't use SQLAlchemy or Tortoise ORM here — we use Supabase's REST API directly.
The model file serves as **documentation** of what the table looks like.

### The 4 Tables and Their Relationships

```
students ──────────────────────────────┐
  id, student_id, name, course...      │
                                       │
subjects ──────────────────────────────┤
  id, code, name, units...             │
         │                             │
         ▼                             │
exams ─────────────────────────────────┤
  id, subject_id (FK), name, type...   │
         │                             │
         ▼                             ▼
exam_results
  id, student_id (FK), exam_id (FK),
  correct_answers, total_score,
  percentage, grade, grade_point...
```

**FK = Foreign Key** — a link between tables.
`exam_results.student_id` points to `students.id`
`exam_results.exam_id` points to `exams.id`
`exams.subject_id` points to `subjects.id`

---

## 7. Schemas — Validating Data

Schemas use **Pydantic** to define what data is allowed in a request.

```python
# schemas/student.py
from pydantic import BaseModel
from typing import Optional

class StudentCreate(BaseModel):
    student_id: str        # required — must be a string
    first_name: str        # required
    last_name:  str        # required
    email:      Optional[str] = None   # optional
    course:     str        # required
    year_level: int = 1    # optional, defaults to 1
```

### What Pydantic Does Automatically

If someone sends this bad request:
```json
{
  "first_name": "John"
}
```

FastAPI automatically returns:
```json
{
  "detail": [
    { "loc": ["body", "student_id"], "msg": "field required" },
    { "loc": ["body", "last_name"],  "msg": "field required" },
    { "loc": ["body", "course"],     "msg": "field required" }
  ]
}
```

You don't write any validation code yourself. Pydantic handles it.

### Create vs Update Schemas

**Create** — all required fields must be present:
```python
class StudentCreate(BaseModel):
    student_id: str   # required
    first_name: str   # required
    course:     str   # required
```

**Update** — all fields are optional (only send what you want to change):
```python
class StudentUpdate(BaseModel):
    first_name: Optional[str] = None  # optional
    course:     Optional[str] = None  # optional
    year_level: Optional[int] = None  # optional
```

### Email Validation

```python
from pydantic import EmailStr

class AuthLogin(BaseModel):
    email:    EmailStr   # automatically validates email format
    password: str
```

If you send `"email": "notanemail"`, Pydantic rejects it automatically.

---

## 8. Controllers — Handling Requests

Controllers are where the actual logic lives.
Each controller file handles one resource (students, subjects, etc.)

### Basic Structure

```python
from fastapi import APIRouter, HTTPException
import httpx
from database import rest_url, get_headers
from schemas import StudentCreate, StudentUpdate
from models.student import TABLE

router = APIRouter(prefix="/students", tags=["Students"])
```

- `APIRouter` — groups related endpoints together
- `prefix="/students"` — all routes in this file start with `/students`
- `tags=["Students"]` — groups them in Swagger UI

### GET — Read All

```python
@router.get("/")
async def get_students():
    async with httpx.AsyncClient() as client:
        res = await client.get(
            rest_url(TABLE),           # URL: /rest/v1/students
            headers=get_headers(),     # API key
            params={"select": "*", "order": "created_at.desc"}
        )
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()
```

Step by step:
1. Open an async HTTP client
2. Send GET request to Supabase
3. If it fails, raise an error
4. Return the data as JSON

### POST — Create

```python
@router.post("/")
async def create_student(body: StudentCreate):
    async with httpx.AsyncClient() as client:
        res = await client.post(
            rest_url(TABLE),
            headers=get_headers(),
            json=body.model_dump()     # converts Pydantic model to dict
        )
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]
```

`body: StudentCreate` — FastAPI automatically validates the request body
`body.model_dump()` — converts the Pydantic object to a plain Python dict

### PUT — Update

```python
@router.put("/{student_id}")
async def update_student(student_id: str, body: StudentUpdate):
    # only include fields that were actually sent (not None)
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    async with httpx.AsyncClient() as client:
        res = await client.patch(
            rest_url(TABLE),
            headers=get_headers(),
            json=data,
            params={"id": f"eq.{student_id}"}   # WHERE id = student_id
        )
    ...
```

`{student_id}` in the path is a **path parameter** — it comes from the URL.
`PUT /students/abc-123` → `student_id = "abc-123"`

`params={"id": f"eq.{student_id}"}` tells Supabase:
> Only update the row WHERE id equals this value

### DELETE — Remove

```python
@router.delete("/{student_id}")
async def delete_student(student_id: str):
    async with httpx.AsyncClient() as client:
        res = await client.delete(
            rest_url(TABLE),
            headers=get_headers(),
            params={"id": f"eq.{student_id}"}
        )
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Student deleted"}
```

### What is `async`?

`async` means the function can pause and let other requests run while waiting.

Without async:
```
Request 1 starts → waits for DB → finishes
Request 2 starts → waits for DB → finishes   (has to wait for Request 1)
```

With async:
```
Request 1 starts → waiting for DB...
Request 2 starts → waiting for DB...          (runs at the same time!)
Request 1 DB responds → finishes
Request 2 DB responds → finishes
```

This makes the API much faster under load.

---

## 9. main.py — Putting It All Together

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controllers import (
    auth_router, students_router, subjects_router,
    exams_router, results_router, dashboard_router, grades_router,
)

app = FastAPI(title="EduScan API", version="1.0.0")
```

### CORS Middleware

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],    # allow requests from any domain
    allow_methods=["*"],    # allow GET, POST, PUT, DELETE, etc.
    allow_headers=["*"],
)
```

**CORS** = Cross-Origin Resource Sharing.
Without this, your Flutter app or web browser would be blocked from calling the API.
`allow_origins=["*"]` means any frontend can call this API.

### Registering Routers

```python
app.include_router(auth_router)
app.include_router(students_router)
app.include_router(subjects_router)
...
```

This connects all the controllers to the main app.
Each router brings its own prefix (`/students`, `/subjects`, etc.)

---

## 10. How a Request Travels Through the Code

Let's trace `POST /students/` with this body:
```json
{
  "student_id": "2024-001",
  "first_name": "Maria",
  "last_name": "Santos",
  "course": "BSCS",
  "year_level": 1
}
```

```
1. Request arrives at FastAPI (main.py)
        ↓
2. FastAPI matches route → controllers/students.py → create_student()
        ↓
3. Pydantic validates body against StudentCreate schema
   - student_id ✓ (string)
   - first_name ✓ (string)
   - last_name  ✓ (string)
   - course     ✓ (string)
   - year_level ✓ (int)
        ↓
4. body.model_dump() converts to:
   {"student_id": "2024-001", "first_name": "Maria", ...}
        ↓
5. httpx sends POST to Supabase REST API
   URL: https://yourproject.supabase.co/rest/v1/students
   Body: {"student_id": "2024-001", ...}
        ↓
6. Supabase inserts row into PostgreSQL
        ↓
7. Supabase returns the created row as JSON
        ↓
8. FastAPI returns it to the client
```

Response:
```json
{
  "id": "uuid-here",
  "student_id": "2024-001",
  "first_name": "Maria",
  "last_name": "Santos",
  "course": "BSCS",
  "year_level": 1,
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

## 11. CRUD Explained

**CRUD = Create, Read, Update, Delete**
These are the 4 basic operations for any data.

| Operation | HTTP Method | Endpoint | What it does |
|-----------|-------------|----------|--------------|
| Create | POST | `/students/` | Add a new student |
| Read | GET | `/students/` | Get all students |
| Update | PUT | `/students/{id}` | Change a student's data |
| Delete | DELETE | `/students/{id}` | Remove a student |

### Supabase REST Filter Syntax

When we send requests to Supabase, we use special filter syntax:

| Filter | Meaning | Example |
|--------|---------|---------|
| `eq.value` | equals | `id=eq.abc-123` |
| `neq.value` | not equals | `year_level=neq.1` |
| `gt.value` | greater than | `year_level=gt.2` |
| `select=*` | get all columns | `select=*` |
| `order=col.desc` | sort descending | `order=created_at.desc` |

---

## 12. Error Handling

```python
if res.status_code != 200:
    raise HTTPException(status_code=res.status_code, detail=res.text)
```

`HTTPException` tells FastAPI to return an error response.

| Status Code | Meaning |
|-------------|---------|
| 200 | OK — success |
| 201 | Created — new record made |
| 204 | No Content — deleted successfully |
| 400 | Bad Request — invalid data |
| 401 | Unauthorized — wrong credentials |
| 404 | Not Found — record doesn't exist |
| 422 | Unprocessable — Pydantic validation failed |
| 500 | Server Error — something crashed |

### Example Error Response

If you try to create a student with a duplicate `student_id`:
```json
{
  "detail": "duplicate key value violates unique constraint"
}
```

---

## 13. MSU Grading Logic

Located in `controllers/results.py`:

```python
def _assign_grade(percentage: float) -> tuple[str, float, str]:
    """Returns (grade, grade_point, remarks)"""
    if percentage >= 96: return "1.0",  1.0,  "Passed"
    if percentage >= 92: return "1.25", 1.25, "Passed"
    if percentage >= 88: return "1.5",  1.5,  "Passed"
    if percentage >= 84: return "1.75", 1.75, "Passed"
    if percentage >= 80: return "2.0",  2.0,  "Passed"
    if percentage >= 76: return "2.25", 2.25, "Passed"
    if percentage >= 72: return "2.5",  2.5,  "Passed"
    if percentage >= 68: return "2.75", 2.75, "Passed"
    if percentage >= 60: return "3.0",  3.0,  "Passed"
    return "5.0", 5.0, "Failed"
```

### MSU Grading Scale

| Percentage | Grade | Grade Point | Description |
|------------|-------|-------------|-------------|
| 96 – 100 | 1.0 | 1.0 | Excellent |
| 92 – 95 | 1.25 | 1.25 | Excellent |
| 88 – 91 | 1.5 | 1.5 | Very Good |
| 84 – 87 | 1.75 | 1.75 | Very Good |
| 80 – 83 | 2.0 | 2.0 | Good |
| 76 – 79 | 2.25 | 2.25 | Good |
| 72 – 75 | 2.5 | 2.5 | Satisfactory |
| 68 – 71 | 2.75 | 2.75 | Satisfactory |
| 60 – 67 | 3.0 | 3.0 | Passing |
| Below 60 | 5.0 | 5.0 | Failed |

### How it's used in POST /results/

```python
@router.post("/")
async def create_result(body: ExamResultCreate):
    data = body.model_dump()

    # if percentage is given but grade is not — auto assign
    if data.get("percentage") is not None and not data.get("grade"):
        grade, gp, remarks = _assign_grade(data["percentage"])
        data["grade"]       = grade   # e.g. "2.0"
        data["grade_point"] = gp      # e.g. 2.0
        data.setdefault("remarks", remarks)  # "Passed" or "Failed"
    ...
```

So when you submit a result with `percentage: 85`, the API automatically:
- Sets `grade` to `"1.75"`
- Sets `grade_point` to `1.75`
- Sets `remarks` to `"Passed"`

---

## 14. GPA Computation

Located in `controllers/grades.py`:

### Formula

```
GPA = Sum of (Grade Point × Units) / Sum of Units
```

### Example

| Subject | Units | Grade Point | Weighted |
|---------|-------|-------------|----------|
| Math | 3 | 1.5 | 4.5 |
| English | 3 | 2.0 | 6.0 |
| PE | 2 | 1.25 | 2.5 |
| **Total** | **8** | — | **13.0** |

```
GPA = 13.0 / 8 = 1.625  →  "Very Good"
```

### The Code

```python
weighted_sum = 0.0
total_units  = 0

for r in results:
    gp    = r.get("grade_point")       # e.g. 1.5
    units = r["exams"]["subjects"]["units"]  # e.g. 3

    weighted_sum += gp * units         # 1.5 × 3 = 4.5
    total_units  += units              # 3

gpa = round(weighted_sum / total_units, 4)
```

### GPA Interpretation

| GPA | Interpretation |
|-----|---------------|
| 1.0 – 1.25 | Excellent |
| 1.26 – 1.75 | Very Good |
| 1.76 – 2.25 | Good |
| 2.26 – 2.75 | Satisfactory |
| 2.76 – 3.0 | Passing |
| Above 3.0 | Failed |

### API Response

```json
{
  "gpa": 1.625,
  "total_units": 8,
  "subjects_counted": 3,
  "interpretation": "Very Good"
}
```

---

## 15. Authentication

Located in `controllers/auth.py`.

### Signup

```python
@router.post("/signup")
async def signup(body: AuthSignup):
    res = await client.post(
        auth_url("signup"),
        json={"email": body.email, "password": body.password},
        headers=_AUTH_HEADERS,
    )
```

Sends the email and password to Supabase Auth.
Supabase handles password hashing — we never store plain passwords.

### Login

```python
@router.post("/login")
async def login(body: AuthLogin):
    res = await client.post(
        auth_url("token?grant_type=password"),
        json={"email": body.email, "password": body.password},
        headers=_AUTH_HEADERS,
    )
    data = res.json()
    return {"access_token": data.get("access_token"), "user": data.get("user")}
```

Returns a **JWT token** on success.

### What is a JWT Token?

JWT = JSON Web Token. It's a string that proves you are logged in.

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLWlkIn0.signature
```

After login, the frontend stores this token and sends it with every request
in the `Authorization: Bearer <token>` header.

---

## 16. Swagger UI

FastAPI automatically generates interactive API documentation.

**URL:** `http://localhost:8000/docs`

What you can do in Swagger UI:
- See all available endpoints
- See what data each endpoint expects
- Send real requests and see real responses
- Test your API without writing any code

### How to test an endpoint in Swagger UI

1. Open `http://localhost:8000/docs`
2. Click on `POST /students/`
3. Click **"Try it out"**
4. Fill in the request body
5. Click **"Execute"**
6. See the response below

---

## 17. test_api.py — Testing the API

This script automatically tests all endpoints.

```python
BASE = "http://localhost:8000"

def run():
    # 1. Create a student
    r = httpx.post(f"{BASE}/students/", json={
        "student_id": "TEST-001",
        "first_name": "Jane",
        "last_name": "Doe",
        "course": "BSCS",
        "year_level": 2
    })
    sid = r.json()["id"]   # save the ID for later

    # 2. Read all students
    httpx.get(f"{BASE}/students/")

    # 3. Update the student
    httpx.put(f"{BASE}/students/{sid}", json={"year_level": 3})

    # 4. Delete the student
    httpx.delete(f"{BASE}/students/{sid}")
```

It creates test data, verifies it works, then cleans up after itself.

### How to run it

```bash
# Terminal 1 — start the server
python -m uvicorn main:app --reload

# Terminal 2 — run the tests
python test_api.py
```

---

## 18. Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `ModuleNotFoundError: No module named 'fastapi'` | Dependencies not installed | Run `pip install -r requirements.txt` |
| `401 Unauthorized` | Wrong Supabase key | Check your `.env` file |
| `422 Unprocessable Entity` | Missing required field | Check what fields the schema requires |
| `Connection refused` | Server not running | Run `python -m uvicorn main:app --reload` |
| `.env not loading` | Wrong file location | Make sure `.env` is inside `backend/` folder |
| `duplicate key value` | student_id already exists | Use a different student_id |
| `'uvicorn' is not recognized` | Not using python -m | Use `python -m uvicorn` instead of just `uvicorn` |

---

## 19. Glossary

| Term | Meaning |
|------|---------|
| **API** | Application Programming Interface — a way for apps to talk to each other |
| **REST** | A style of API that uses HTTP methods (GET, POST, PUT, DELETE) |
| **Endpoint** | A specific URL that does something, e.g. `/students/` |
| **HTTP Method** | The type of request: GET (read), POST (create), PUT (update), DELETE (remove) |
| **JSON** | JavaScript Object Notation — the data format APIs use |
| **Pydantic** | Python library for data validation |
| **Schema** | A definition of what data looks like |
| **Model** | Represents a database table |
| **Controller** | Handles incoming requests and returns responses |
| **Router** | Groups related endpoints together |
| **Middleware** | Code that runs on every request before it reaches your endpoint |
| **CORS** | Security rule that controls which websites can call your API |
| **JWT** | JSON Web Token — a string that proves you are logged in |
| **UUID** | Universally Unique Identifier — a random ID like `abc-123-def-456` |
| **FK** | Foreign Key — a column that links to another table |
| **async/await** | Python syntax for running code without blocking other requests |
| **httpx** | Python library for making HTTP requests |
| **Supabase** | Cloud database service (PostgreSQL + REST API + Auth) |
| **Uvicorn** | The server that runs FastAPI |
| **GPA** | Grade Point Average — weighted average of all grades |
| **CRUD** | Create, Read, Update, Delete — the 4 basic data operations |
