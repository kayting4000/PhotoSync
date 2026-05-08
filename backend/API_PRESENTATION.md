# EduScan Backend API
### Presentation Guide — FastAPI + Supabase

---

## Slide 1: Title

# 📱 EduScan
## Smart Test Paper Scanner & Grade Management System
### Backend API Documentation

**Created by:** Habibun-najal K. Kayting
**Email:** kayting4k@gmail.com
**Tech Stack:** FastAPI · Supabase · Python · Roboflow AI

---

## Slide 2: What is EduScan?

EduScan is a **complete grade management system** that allows teachers to:

- 👥 Manage students and subjects
- 📸 Scan test papers using **Roboflow AI** to detect checkmarks
- 📊 Track grades and calculate GPA automatically
- 📧 Send grade reports to students via email
- 📈 View dashboard statistics in real-time

---

## Slide 3: System Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Mobile App                  │
│              (Android / iOS / Web)                   │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP Requests
                       ▼
┌─────────────────────────────────────────────────────┐
│              FastAPI Backend (Python)                │
│         REST API — localhost:8000 / online           │
└──────────┬──────────────────────┬───────────────────┘
           │                      │
           ▼                      ▼
┌──────────────────┐   ┌─────────────────────────────┐
│  Supabase        │   │  Roboflow AI                 │
│  - PostgreSQL DB │   │  - Checkmark Detection       │
│  - Auth          │   │  - Count & Visualize         │
│  - Storage       │   │  - Model: checkmark-wif8k/1  │
└──────────────────┘   └─────────────────────────────┘
```

---

## Slide 4: Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter + Dart | Cross-platform UI |
| **Backend API** | FastAPI (Python) | REST API server |
| **Database** | Supabase (PostgreSQL) | Data storage |
| **Authentication** | Supabase Auth | User login/signup |
| **AI Scanner** | Roboflow | Checkmark detection |
| **HTTP Client** | httpx | API calls |
| **Data Validation** | Pydantic | Request/response models |
| **Navigation** | GoRouter | App routing |
| **State Management** | Provider | Flutter state |

---

## Slide 5: API Base URL & Setup

```
Base URL:  http://localhost:8000
Docs URL:  http://localhost:8000/docs
```

### How to Run
```bash
# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Environment Variables (.env)
```env
SUPABASE_URL=https://spbzddkeklaexgukmrxn.supabase.co
SUPABASE_KEY=your_supabase_anon_key
```

---

## Slide 6: Authentication Endpoints

### POST /auth/signup
Register a new user account.

**Request Body:**
```json
{
  "email": "teacher@school.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "message": "Signup successful",
  "user": { "id": "uuid", "email": "teacher@school.com" }
}
```

---

### POST /auth/login
Login and receive access token.

**Request Body:**
```json
{
  "email": "teacher@school.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": "uuid", "email": "teacher@school.com" }
}
```

---

## Slide 7: Students Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/students` | Get all students |
| `POST` | `/students` | Add new student |
| `PUT` | `/students/{id}` | Update student |
| `DELETE` | `/students/{id}` | Delete student |

### POST /students — Request Body
```json
{
  "student_id": "2021-00001",
  "first_name": "Juan",
  "last_name": "Dela Cruz",
  "email": "juan@email.com",
  "course": "BSIT",
  "year_level": 2
}
```

### GET /students — Response
```json
[
  {
    "id": "uuid",
    "student_id": "2021-00001",
    "first_name": "Juan",
    "last_name": "Dela Cruz",
    "course": "BSIT",
    "year_level": 2,
    "created_at": "2024-01-01T00:00:00"
  }
]
```

---

## Slide 8: Subjects Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/subjects` | Get all subjects |
| `POST` | `/subjects` | Add new subject |
| `PUT` | `/subjects/{id}` | Update subject |
| `DELETE` | `/subjects/{id}` | Delete subject |

### POST /subjects — Request Body
```json
{
  "code": "IT101",
  "name": "Introduction to Computing",
  "units": 3
}
```

---

## Slide 9: Exams Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/exams` | Get all exams |
| `GET` | `/exams?subject_id=uuid` | Filter by subject |
| `POST` | `/exams` | Create exam |
| `DELETE` | `/exams/{id}` | Delete exam |

### POST /exams — Request Body
```json
{
  "subject_id": "uuid",
  "name": "Midterm Exam",
  "exam_type": "midterm",
  "total_items": 50,
  "points_per_item": 2.0,
  "passing_score": 60.0
}
```

---

## Slide 10: Exam Results Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/results` | Get all results |
| `GET` | `/results?student_id=uuid` | Filter by student |
| `POST` | `/results` | Save exam result |
| `DELETE` | `/results/{id}` | Delete result |

### POST /results — Request Body
```json
{
  "student_id": "uuid",
  "exam_id": "uuid",
  "correct_answers": 42,
  "total_score": 84.0,
  "percentage": 84.0
}
```

### Auto Grade Calculation
```
90-100% → A+
85-89%  → A
80-84%  → B+
75-79%  → B
70-74%  → C+
65-69%  → C
60-64%  → D
Below   → F
```

---

## Slide 11: Dashboard & GPA Endpoints

### GET /dashboard
Returns total counts for all data.

**Response:**
```json
{
  "total_students": 45,
  "total_subjects": 8,
  "total_exams": 12,
  "total_results": 180
}
```

---

### GET /gpa
Calculate GPA for all students or a specific student.

**Query Params:** `?student_id=uuid` (optional)

**Response:**
```json
{
  "gpa": 3.25,
  "average_percentage": 81.5
}
```

### GPA Formula
```
average_percentage = sum(all percentages) / count
gpa = (average_percentage / 100 × 3.0) + 1.0
gpa = clamped between 1.0 and 4.0
```

---

## Slide 12: Roboflow AI Scanner

### How It Works

```
1. Teacher takes photo of test paper
         ↓
2. Image converted to Base64
         ↓
3. Sent to Roboflow API
   POST https://serverless.roboflow.com/
   workspace: kayting-habibun-najal
   workflow:  detect-count-and-visualize-2
         ↓
4. AI detects and counts checkmarks
         ↓
5. Returns count + visualized image
         ↓
6. Score saved to Supabase database
```

### Roboflow API Call
```python
result = client.run_workflow(
    workspace_name="kayting-habibun-najal",
    workflow_id="detect-count-and-visualize-2",
    images={"image": "YOUR_IMAGE.jpg"},
    use_cache=True
)
```

---

## Slide 13: Database Schema

```sql
-- Students Table
students (
  id          UUID PRIMARY KEY,
  student_id  TEXT UNIQUE,
  first_name  TEXT,
  last_name   TEXT,
  email       TEXT,
  course      TEXT,
  year_level  INTEGER,
  created_at  TIMESTAMP
)

-- Subjects Table
subjects (
  id         UUID PRIMARY KEY,
  code       TEXT UNIQUE,
  name       TEXT,
  units      INTEGER,
  created_at TIMESTAMP
)

-- Exams Table
exams (
  id              UUID PRIMARY KEY,
  subject_id      UUID REFERENCES subjects,
  name            TEXT,
  exam_type       TEXT,
  total_items     INTEGER,
  points_per_item FLOAT,
  passing_score   FLOAT,
  created_at      TIMESTAMP
)

-- Exam Results Table
exam_results (
  id                UUID PRIMARY KEY,
  student_id        UUID REFERENCES students,
  exam_id           UUID REFERENCES exams,
  correct_answers   INTEGER,
  total_score       FLOAT,
  percentage        FLOAT,
  grade             TEXT,
  scanned_image_url TEXT,
  created_at        TIMESTAMP
)
```

---

## Slide 14: Security

| Feature | Implementation |
|---------|---------------|
| **Authentication** | Supabase JWT tokens |
| **Row Level Security** | Supabase RLS policies |
| **CORS** | Configured in FastAPI middleware |
| **Environment Variables** | Credentials in `.env` file |
| **HTTPS** | Enforced by Supabase |
| **Input Validation** | Pydantic models |

---

## Slide 15: Project File Structure

```
EduScan/
├── 📁 backend/                  ← FastAPI Backend
│   ├── main.py                  ← All API routes
│   ├── database.py              ← Supabase connection
│   ├── models.py                ← Pydantic data models
│   ├── requirements.txt         ← Python dependencies
│   └── .env                     ← Environment variables
│
└── 📁 flutter_app/              ← Flutter Mobile App
    ├── lib/
    │   ├── main.dart            ← App entry point
    │   ├── theme/app_theme.dart ← Glassmorphism UI
    │   ├── providers/           ← State management
    │   ├── screens/             ← UI screens
    │   ├── models/              ← Data models
    │   └── widgets/             ← Reusable widgets
    ├── android/                 ← Android config
    └── pubspec.yaml             ← Flutter dependencies
```

---

## Slide 16: API Summary

| # | Method | Endpoint | Description |
|---|--------|----------|-------------|
| 1 | GET | `/` | Health check |
| 2 | POST | `/auth/signup` | Register user |
| 3 | POST | `/auth/login` | Login |
| 4 | GET | `/students` | List students |
| 5 | POST | `/students` | Add student |
| 6 | PUT | `/students/{id}` | Update student |
| 7 | DELETE | `/students/{id}` | Delete student |
| 8 | GET | `/subjects` | List subjects |
| 9 | POST | `/subjects` | Add subject |
| 10 | PUT | `/subjects/{id}` | Update subject |
| 11 | DELETE | `/subjects/{id}` | Delete subject |
| 12 | GET | `/exams` | List exams |
| 13 | POST | `/exams` | Add exam |
| 14 | DELETE | `/exams/{id}` | Delete exam |
| 15 | GET | `/results` | List results |
| 16 | POST | `/results` | Save result |
| 17 | DELETE | `/results/{id}` | Delete result |
| 18 | GET | `/dashboard` | Stats overview |
| 19 | GET | `/gpa` | Calculate GPA |

---

## Slide 17: How to Test the API

1. Start the server:
```bash
uvicorn main:app --reload
```

2. Open Swagger UI:
```
http://localhost:8000/docs
```

3. Test endpoints interactively — no Postman needed!

---

## Slide 18: Creator

```
╔══════════════════════════════════════╗
║           EduScan Project            ║
║                                      ║
║  Creator: Habibun-najal K. Kayting   ║
║  Email:   kayting4k@gmail.com        ║
║  GitHub:  github.com/kayting4000     ║
║                                      ║
║  Built with ❤️ using                 ║
║  Flutter · FastAPI · Supabase        ║
║  Roboflow AI · Python · Dart         ║
╚══════════════════════════════════════╝
```

---

*This document can be used to create a PowerPoint presentation.
Each section marked with `## Slide X` represents one slide.*
