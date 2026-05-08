# EduScan Backend API

FastAPI backend for EduScan — Test Paper Scanner & Grade Management System.

---

## 🗂 Project Structure (MVC)

```
backend/
├── main.py               # Entry point — registers all routers
├── database.py           # Supabase connection config
├── requirements.txt      # Python dependencies
├── test_api.py           # Smoke test script
├── .env                  # Environment variables (not committed)
│
├── models/               # M — Table schema definitions
│   ├── student.py
│   ├── subject.py
│   ├── exam.py
│   └── exam_result.py
│
├── schemas/              # V — Pydantic request/response validation
│   ├── auth.py
│   ├── student.py
│   ├── subject.py
│   ├── exam.py
│   └── exam_result.py
│
└── controllers/          # C — Route handlers (business logic)
    ├── auth.py
    ├── students.py
    ├── subjects.py
    ├── exams.py
    ├── results.py
    ├── dashboard.py
    └── grades.py
```

---

## ✅ Requirements

- Python **3.10+**
- A [Supabase](https://supabase.com) project with tables: `students`, `subjects`, `exams`, `exam_results`

---

## 🚀 How to Run the Backend

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

Then activate it:

**Windows:**
```bash
venv\Scripts\activate
```

**macOS / Linux:**
```bash
source venv/bin/activate
```

> You should see `(venv)` appear at the start of your terminal line.

---

### Step 3 — Install dependencies

```bash
pip install -r requirements.txt
```

---

### Step 4 — Create the `.env` file

Create a file named `.env` inside the `backend/` folder with your Supabase credentials:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

> 📌 Get these from your Supabase dashboard → **Project Settings → API**

---

### Step 5 — Start the server

```bash
python -m uvicorn main:app --reload
```

You should see:

```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process using WatchFiles
```

---

### Step 6 — Open the API docs

| Interface | URL |
|-----------|-----|
| 📄 Swagger UI (interactive) | http://localhost:8000/docs |
| 📘 ReDoc | http://localhost:8000/redoc |
| ❤️ Health check | http://localhost:8000/ |

---

## 🧪 Running Tests

Make sure the server is **already running**, then open a **second terminal** and run:

```bash
cd EduScan/backend
python test_api.py
```

Expected output:

```
=== EduScan API Tests ===

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

## 📡 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/signup` | Register a new user |
| `POST` | `/auth/login` | Login and get access token |

### Students
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/students/` | List all students |
| `POST` | `/students/` | Create a student |
| `PUT` | `/students/{id}` | Update a student |
| `DELETE` | `/students/{id}` | Delete a student |

### Subjects
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/subjects/` | List all subjects |
| `POST` | `/subjects/` | Create a subject |
| `PUT` | `/subjects/{id}` | Update a subject |
| `DELETE` | `/subjects/{id}` | Delete a subject |

### Exams
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/exams/` | List all exams (filter: `?subject_id=`) |
| `POST` | `/exams/` | Create an exam |
| `DELETE` | `/exams/{id}` | Delete an exam |

### Results
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/results/` | List results (filter: `?student_id=` or `?exam_id=`) |
| `POST` | `/results/` | Submit an exam result |
| `DELETE` | `/results/{id}` | Delete a result |

### Dashboard & Grades
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/dashboard/` | Total counts overview |
| `GET` | `/gpa/` | GPA calculation (filter: `?student_id=`) |
| `GET` | `/` | Health check |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | FastAPI |
| Language | Python 3.10+ |
| Validation | Pydantic v2 |
| HTTP Client | httpx (async) |
| Database | Supabase (PostgreSQL) |
| Server | Uvicorn |

---

## ❓ Troubleshooting

| Problem | Fix |
|---------|-----|
| `'uvicorn' is not recognized` | Use `python -m uvicorn main:app --reload` instead |
| `ModuleNotFoundError` | Make sure venv is activated and you ran `pip install -r requirements.txt` |
| `401 Unauthorized` | Check your `.env` — make sure `SUPABASE_KEY` is correct |
| `.env` not loading | Make sure the `.env` file is inside the `backend/` folder, not the root |
