# EduScan Backend API

FastAPI backend for EduScan — Test Paper Scanner & Grade Management System.

---

## Project Structure (MVC)

```
backend/
├── main.py               # App entry point — registers all routers
├── database.py           # Supabase connection config
├── requirements.txt      # Python dependencies
├── test_api.py           # Smoke test script
├── .env                  # Environment variables (not committed)
├── models/               # M — Table schema definitions
│   ├── student.py
│   ├── subject.py
│   ├── exam.py
│   └── exam_result.py
├── schemas/              # V — Pydantic request/response validation
│   ├── auth.py
│   ├── student.py
│   ├── subject.py
│   ├── exam.py
│   └── exam_result.py
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

## Requirements

- Python 3.10+
- A [Supabase](https://supabase.com) project with the following tables:
  `students`, `subjects`, `exams`, `exam_results`

---

## Setup & Run

### 1. Clone the repository
```bash
git clone https://github.com/kayting4000/EduScan.git
cd EduScan/backend
```

### 2. Create and activate a virtual environment
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

Create a `.env` file inside the `backend/` folder:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

> Get these from your Supabase project → Settings → API

### 5. Run the server
```bash
python -m uvicorn main:app --reload
```

Server runs at: **http://localhost:8000**

---

## API Documentation

FastAPI auto-generates interactive docs:

| UI | URL |
|----|-----|
| Swagger UI | http://localhost:8000/docs |
| ReDoc | http://localhost:8000/redoc |

---

## API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/signup` | Register new user |
| POST | `/auth/login` | Login and get access token |

### Students
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/students/` | List all students |
| POST | `/students/` | Create a student |
| PUT | `/students/{id}` | Update a student |
| DELETE | `/students/{id}` | Delete a student |

### Subjects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/subjects/` | List all subjects |
| POST | `/subjects/` | Create a subject |
| PUT | `/subjects/{id}` | Update a subject |
| DELETE | `/subjects/{id}` | Delete a subject |

### Exams
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/exams/` | List all exams (filter by `?subject_id=`) |
| POST | `/exams/` | Create an exam |
| DELETE | `/exams/{id}` | Delete an exam |

### Results
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/results/` | List results (filter by `?student_id=` or `?exam_id=`) |
| POST | `/results/` | Submit an exam result |
| DELETE | `/results/{id}` | Delete a result |

### Dashboard & Grades
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard/` | Total counts overview |
| GET | `/gpa/` | GPA calculation (filter by `?student_id=`) |
| GET | `/` | Health check |

---

## Running Tests

Make sure the server is running first, then in a separate terminal:

```bash
python test_api.py
```

The script will create, read, update, and delete records across all entities and print pass/fail for each endpoint.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | FastAPI |
| Language | Python 3.10+ |
| Validation | Pydantic v2 |
| HTTP Client | httpx (async) |
| Database | Supabase (PostgreSQL) |
| Server | Uvicorn |
