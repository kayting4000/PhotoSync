# EduScan Backend API

FastAPI backend for EduScan — Test Paper Scanner & Grade Management System.
Built for **Mindanao State University - Tawi-Tawi (MSU-Tawi-Tawi)**.

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

Activate it:

**Windows:**
```bash
venv\Scripts\activate
```

**macOS / Linux:**
```bash
source venv/bin/activate
```

---

### Step 3 — Install dependencies

```bash
pip install -r requirements.txt
```

---

### Step 4 — Create the `.env` file

Create a file named `.env` inside the `backend/` folder:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

> Get these from your Supabase dashboard → **Project Settings → API**

---

### Step 5 — Start the server

```bash
python -m uvicorn main:app --reload
```

---

### Step 6 — Open the API docs

| Interface | URL |
|-----------|-----|
| Swagger UI (interactive) | http://localhost:8000/docs |
| ReDoc | http://localhost:8000/redoc |
| Health check | http://localhost:8000/ |

---

## 🧪 Running Tests

Make sure the server is **already running**, then in a second terminal:

```bash
cd EduScan/backend
python test_api.py
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

### Dashboard & GPA
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/dashboard/` | Total counts overview |
| `GET` | `/gpa/` | Weighted GPA (filter: `?student_id=`) |
| `GET` | `/` | Health check |

---

## 🎓 MSU-Tawi-Tawi Grading Scale

Grades are automatically assigned from the exam percentage score using the official MSU grading scale.

| Percentage Range | Grade | Grade Point | Description |
|-----------------|-------|-------------|-------------|
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

### GPA Computation

GPA is computed using the **weighted average** formula:

```
GPA = Σ(Grade Point × Units) / Σ(Units)
```

**Example:**

| Subject | Units | Grade Point | Weighted |
|---------|-------|-------------|----------|
| Math | 3 | 1.5 | 4.5 |
| English | 3 | 2.0 | 6.0 |
| PE | 2 | 1.25 | 2.5 |
| **Total** | **8** | — | **13.0** |

```
GPA = 13.0 / 8 = 1.625
```

### GPA Interpretation

| GPA Range | Interpretation |
|-----------|---------------|
| 1.0 – 1.25 | Excellent |
| 1.26 – 1.75 | Very Good |
| 1.76 – 2.25 | Good |
| 2.26 – 2.75 | Satisfactory |
| 2.76 – 3.0 | Passing |
| Above 3.0 | Failed |

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
| `'uvicorn' is not recognized` | Use `python -m uvicorn main:app --reload` |
| `ModuleNotFoundError` | Activate venv and run `pip install -r requirements.txt` |
| `401 Unauthorized` | Check `.env` — verify `SUPABASE_KEY` is correct |
| `.env` not loading | Make sure `.env` is inside `backend/`, not the project root |
