# EduScan Backend API
### Presentation Guide — FastAPI + Supabase

---

## Slide 1: Title

# EduScan
## Smart Test Paper Scanner & Grade Management System
### Backend API Documentation

**Development Team:**
- Habibun-najal Kayting — Lead Developer
- Hareeja Montenegro — Sub-developer & Quality Assurance
- Mohd Shaffiqh Anang — Sub-developer & Documentation

**Tech Stack:** FastAPI · Supabase · Python · Roboflow AI

---

## Slide 2: What is EduScan?

EduScan is a **complete grade management system** that allows teachers to:

- Manage students and subjects
- Scan test papers using **Roboflow AI** to detect checkmarks
- Track grades and calculate GPA automatically
- Send grade reports to students via email
- View dashboard statistics in real-time

---

## Slide 3: System Architecture

```
+-----------------------------------------------------+
|                  Flutter Mobile App                  |
|              (Android / iOS / Web)                   |
+----------------------+------------------------------+
                       | HTTP Requests
                       v
+-----------------------------------------------------+
|              FastAPI Backend (Python)                |
|         REST API - localhost:8000 / online           |
+----------+----------------------+-------------------+
           |                      |
           v                      v
+------------------+   +-----------------------------+
|  Supabase        |   |  Roboflow AI                |
|  - PostgreSQL DB |   |  - Checkmark Detection      |
|  - Auth          |   |  - Count & Visualize        |
|  - Storage       |   |  - Workspace: kayting-      |
+------------------+   |    habibun-najal            |
                       +-----------------------------+
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
pip install -r requirements.txt
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
```json
Request:  { "email": "teacher@school.com", "password": "pass" }
Response: { "message": "Signup successful", "user": { "id": "uuid" } }
```

### POST /auth/login
```json
Request:  { "email": "teacher@school.com", "password": "pass" }
Response: { "access_token": "eyJ...", "user": { "id": "uuid" } }
```

---

## Slide 7: Students Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /students | Get all students |
| POST | /students | Add new student |
| PUT | /students/{id} | Update student |
| DELETE | /students/{id} | Delete student |

### POST /students
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

---

## Slide 8: Subjects Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /subjects | Get all subjects |
| POST | /subjects | Add new subject |
| PUT | /subjects/{id} | Update subject |
| DELETE | /subjects/{id} | Delete subject |

### POST /subjects
```json
{ "code": "IT101", "name": "Introduction to Computing", "units": 3 }
```

---

## Slide 9: Exams Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /exams | Get all exams |
| GET | /exams?subject_id=uuid | Filter by subject |
| POST | /exams | Create exam |
| DELETE | /exams/{id} | Delete exam |

### POST /exams
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
| GET | /results | Get all results |
| GET | /results?student_id=uuid | Filter by student |
| POST | /results | Save exam result |
| DELETE | /results/{id} | Delete result |

### Auto Grade Calculation
```
90-100% = A+    75-79% = B
85-89%  = A     70-74% = C+
80-84%  = B+    65-69% = C
                60-64% = D
                Below  = F
```

---

## Slide 11: Dashboard & GPA Endpoints

### GET /dashboard
```json
{
  "total_students": 45,
  "total_subjects": 8,
  "total_exams": 12,
  "total_results": 180
}
```

### GET /gpa
```json
{ "gpa": 3.25, "average_percentage": 81.5 }
```

### GPA Formula
```
avg = sum(all percentages) / count
gpa = (avg / 100 x 3.0) + 1.0
gpa = clamped between 1.0 and 4.0
```

---

## Slide 12: Roboflow AI Scanner

### How It Works
```
1. Teacher takes photo of test paper
2. Image converted to Base64
3. Sent to Roboflow API
   - workspace: kayting-habibun-najal
   - workflow:  detect-count-and-visualize-2
4. AI detects and counts checkmarks
5. Returns count + visualized image
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
students    (id, student_id, first_name, last_name, email, course, year_level)
subjects    (id, code, name, units)
exams       (id, subject_id, name, exam_type, total_items, points_per_item)
exam_results(id, student_id, exam_id, correct_answers, total_score, percentage, grade)
```

---

## Slide 14: Security

| Feature | Implementation |
|---------|---------------|
| Authentication | Supabase JWT tokens |
| Row Level Security | Supabase RLS policies |
| CORS | FastAPI middleware |
| Credentials | .env file |
| HTTPS | Enforced by Supabase |
| Input Validation | Pydantic models |

---

## Slide 15: Project File Structure

```
EduScan/
├── backend/
│   ├── main.py          - All API routes
│   ├── database.py      - Supabase connection
│   ├── models.py        - Pydantic data models
│   ├── requirements.txt - Python dependencies
│   └── .env             - Environment variables
│
└── flutter_app/
    ├── lib/
    │   ├── main.dart            - App entry point
    │   ├── theme/app_theme.dart - Glassmorphism UI
    │   ├── providers/           - State management
    │   ├── screens/             - UI screens
    │   └── models/              - Data models
    └── pubspec.yaml
```

---

## Slide 16: Full API Summary

| # | Method | Endpoint | Description |
|---|--------|----------|-------------|
| 1 | GET | / | Health check |
| 2 | POST | /auth/signup | Register user |
| 3 | POST | /auth/login | Login |
| 4 | GET | /students | List students |
| 5 | POST | /students | Add student |
| 6 | PUT | /students/{id} | Update student |
| 7 | DELETE | /students/{id} | Delete student |
| 8 | GET | /subjects | List subjects |
| 9 | POST | /subjects | Add subject |
| 10 | PUT | /subjects/{id} | Update subject |
| 11 | DELETE | /subjects/{id} | Delete subject |
| 12 | GET | /exams | List exams |
| 13 | POST | /exams | Add exam |
| 14 | DELETE | /exams/{id} | Delete exam |
| 15 | GET | /results | List results |
| 16 | POST | /results | Save result |
| 17 | DELETE | /results/{id} | Delete result |
| 18 | GET | /dashboard | Stats overview |
| 19 | GET | /gpa | Calculate GPA |

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

3. Test all endpoints interactively — no Postman needed!

---

## Slide 18: Development Team

| Role | Name | Contact |
|------|------|---------|
| Lead Developer | Habibun-najal Kayting | kayting4k@gmail.com |
| Sub-developer & Quality Assurance | Hareeja Montenegro | — |
| Sub-developer & Documentation | Mohd Shaffiqh Anang | — |

**GitHub:** github.com/kayting4000/EduScan

**Built with Flutter · FastAPI · Supabase · Roboflow AI**

---

*Each section marked with ## Slide X represents one presentation slide.*
