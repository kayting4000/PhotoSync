import httpx
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from database import rest_url, auth_url, get_headers, SUPABASE_KEY
from models import (
    StudentCreate, StudentUpdate,
    SubjectCreate, SubjectUpdate,
    ExamCreate, ExamResultCreate,
    AuthLogin, AuthSignup,
)

app = FastAPI(
    title="EduScan API",
    description="Backend API for EduScan - Test Paper Scanner & Grade Management",
    version="1.0.0",
    contact={
        "name": "Habibun-najal K. Kayting",
        "email": "kayting4k@gmail.com",
    },
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Auth ──────────────────────────────────────────────────────────────────────

@app.post("/auth/signup", tags=["Auth"])
def signup(body: AuthSignup):
    with httpx.Client() as client:
        res = client.post(
            auth_url("signup"),
            json={"email": body.email, "password": body.password},
            headers={"apikey": SUPABASE_KEY, "Content-Type": "application/json"},
        )
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.json())
    return res.json()


@app.post("/auth/login", tags=["Auth"])
def login(body: AuthLogin):
    with httpx.Client() as client:
        res = client.post(
            auth_url("token?grant_type=password"),
            json={"email": body.email, "password": body.password},
            headers={"apikey": SUPABASE_KEY, "Content-Type": "application/json"},
        )
    if res.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    data = res.json()
    return {"access_token": data.get("access_token"), "user": data.get("user")}


# ── Students ──────────────────────────────────────────────────────────────────

@app.get("/students", tags=["Students"])
def get_students():
    with httpx.Client() as client:
        res = client.get(rest_url("students"), headers=get_headers(),
                         params={"select": "*", "order": "created_at.desc"})
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@app.post("/students", tags=["Students"])
def create_student(body: StudentCreate):
    with httpx.Client() as client:
        res = client.post(rest_url("students"), headers=get_headers(),
                          json=body.model_dump())
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.put("/students/{student_id}", tags=["Students"])
def update_student(student_id: str, body: StudentUpdate):
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    with httpx.Client() as client:
        res = client.patch(rest_url("students"), headers=get_headers(),
                           json=data, params={"id": f"eq.{student_id}"})
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.delete("/students/{student_id}", tags=["Students"])
def delete_student(student_id: str):
    with httpx.Client() as client:
        res = client.delete(rest_url("students"), headers=get_headers(),
                            params={"id": f"eq.{student_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Student deleted"}


# ── Subjects ──────────────────────────────────────────────────────────────────

@app.get("/subjects", tags=["Subjects"])
def get_subjects():
    with httpx.Client() as client:
        res = client.get(rest_url("subjects"), headers=get_headers(),
                         params={"select": "*", "order": "created_at.desc"})
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@app.post("/subjects", tags=["Subjects"])
def create_subject(body: SubjectCreate):
    with httpx.Client() as client:
        res = client.post(rest_url("subjects"), headers=get_headers(),
                          json=body.model_dump())
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.put("/subjects/{subject_id}", tags=["Subjects"])
def update_subject(subject_id: str, body: SubjectUpdate):
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    with httpx.Client() as client:
        res = client.patch(rest_url("subjects"), headers=get_headers(),
                           json=data, params={"id": f"eq.{subject_id}"})
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.delete("/subjects/{subject_id}", tags=["Subjects"])
def delete_subject(subject_id: str):
    with httpx.Client() as client:
        res = client.delete(rest_url("subjects"), headers=get_headers(),
                            params={"id": f"eq.{subject_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Subject deleted"}


# ── Exams ─────────────────────────────────────────────────────────────────────

@app.get("/exams", tags=["Exams"])
def get_exams(subject_id: Optional[str] = Query(None)):
    params = {"select": "*", "order": "created_at.desc"}
    if subject_id:
        params["subject_id"] = f"eq.{subject_id}"
    with httpx.Client() as client:
        res = client.get(rest_url("exams"), headers=get_headers(), params=params)
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@app.post("/exams", tags=["Exams"])
def create_exam(body: ExamCreate):
    with httpx.Client() as client:
        res = client.post(rest_url("exams"), headers=get_headers(),
                          json=body.model_dump())
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.delete("/exams/{exam_id}", tags=["Exams"])
def delete_exam(exam_id: str):
    with httpx.Client() as client:
        res = client.delete(rest_url("exams"), headers=get_headers(),
                            params={"id": f"eq.{exam_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Exam deleted"}


# ── Exam Results ──────────────────────────────────────────────────────────────

@app.get("/results", tags=["Results"])
def get_results(student_id: Optional[str] = Query(None),
                exam_id: Optional[str] = Query(None)):
    params = {"select": "*", "order": "created_at.desc"}
    if student_id:
        params["student_id"] = f"eq.{student_id}"
    if exam_id:
        params["exam_id"] = f"eq.{exam_id}"
    with httpx.Client() as client:
        res = client.get(rest_url("exam_results"), headers=get_headers(), params=params)
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@app.post("/results", tags=["Results"])
def create_result(body: ExamResultCreate):
    data = body.model_dump()
    if data.get("percentage") and not data.get("grade"):
        p = data["percentage"]
        if p >= 90: data["grade"] = "A+"
        elif p >= 85: data["grade"] = "A"
        elif p >= 80: data["grade"] = "B+"
        elif p >= 75: data["grade"] = "B"
        elif p >= 70: data["grade"] = "C+"
        elif p >= 65: data["grade"] = "C"
        elif p >= 60: data["grade"] = "D"
        else: data["grade"] = "F"
    with httpx.Client() as client:
        res = client.post(rest_url("exam_results"), headers=get_headers(), json=data)
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@app.delete("/results/{result_id}", tags=["Results"])
def delete_result(result_id: str):
    with httpx.Client() as client:
        res = client.delete(rest_url("exam_results"), headers=get_headers(),
                            params={"id": f"eq.{result_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Result deleted"}


# ── Dashboard ─────────────────────────────────────────────────────────────────

@app.get("/dashboard", tags=["Dashboard"])
def get_dashboard_stats():
    with httpx.Client() as client:
        h = get_headers()
        h["Prefer"] = "count=exact"
        students = client.get(rest_url("students"), headers=h,
                              params={"select": "id"})
        subjects = client.get(rest_url("subjects"), headers=h,
                              params={"select": "id"})
        exams = client.get(rest_url("exams"), headers=h,
                           params={"select": "id"})
        results = client.get(rest_url("exam_results"), headers=h,
                             params={"select": "id"})
    return {
        "total_students": len(students.json()),
        "total_subjects": len(subjects.json()),
        "total_exams": len(exams.json()),
        "total_results": len(results.json()),
    }


# ── GPA ───────────────────────────────────────────────────────────────────────

@app.get("/gpa", tags=["Grades"])
def get_gpa(student_id: Optional[str] = Query(None)):
    params = {"select": "percentage"}
    if student_id:
        params["student_id"] = f"eq.{student_id}"
    with httpx.Client() as client:
        res = client.get(rest_url("exam_results"), headers=get_headers(), params=params)
    results = res.json()
    if not results:
        return {"gpa": 0.0, "average_percentage": 0.0}
    avg = sum(r["percentage"] or 0 for r in results) / len(results)
    gpa = round(max(1.0, min(4.0, avg / 100 * 3.0 + 1.0)), 2)
    return {"gpa": gpa, "average_percentage": round(avg, 2)}


# ── Health ────────────────────────────────────────────────────────────────────

@app.get("/", tags=["Health"])
def root():
    return {
        "app": "EduScan API",
        "version": "1.0.0",
        "status": "running",
        "creator": "Habibun-najal K. Kayting",
        "email": "kayting4k@gmail.com",
        "docs": "/docs",
    }
