"""
EduScan API — FastAPI application with Neon PostgreSQL.
Run: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import engine, Base
from models import User, Student, Subject, Exam, ExamResult, StudentSubject, ScoringRule  # noqa: F401 — register models

from controllers import (
    auth_router,
    students_router,
    subjects_router,
    exams_router,
    results_router,
    dashboard_router,
    grades_router,
    scanner_router,
    student_subjects_router,
    scoring_rules_router,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create tables on startup (safe — uses IF NOT EXISTS)."""
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="EduScan API",
    description="Backend API for EduScan — Test Paper Scanner & Grade Management (Neon PostgreSQL)",
    version="1.0.0",
    lifespan=lifespan,
    contact={"name": "Habibun-najal K. Kayting", "email": "kayting4k@gmail.com"},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(students_router)
app.include_router(subjects_router)
app.include_router(exams_router)
app.include_router(results_router)
app.include_router(dashboard_router)
app.include_router(grades_router)
app.include_router(scanner_router)
app.include_router(student_subjects_router)
app.include_router(scoring_rules_router)


@app.get("/", tags=["Health"])
def root():
    return {
        "app": "EduScan API",
        "version": "1.0.0",
        "database": "Neon PostgreSQL",
        "status": "running",
        "docs": "/docs",
    }