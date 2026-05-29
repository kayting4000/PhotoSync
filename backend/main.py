"""
PhotoSync API — FastAPI application with Neon PostgreSQL.
Run: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""
import os
from contextlib import asynccontextmanager
import logging
from pathlib import Path
from dotenv import load_dotenv

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from database import engine, Base
from models import User, Student, Subject, Exam, ExamResult, StudentSubject, ScoringRule, Section, AcademicTerm, Attendance, GpaConfig  # noqa: F401
from scripts.ensure_columns import ensure_columns

from controllers import (
    auth_router,
    exams_router,
    results_router,
    dashboard_router,
    grades_router,
    scanner_router,
    scan_uploads_router,
    email_router,
    scoring_rules_router,
    academic_terms_router,
    attendance_router,
    gpa_config_router,
)
from controllers.subjects import router as subjects_router
from controllers.sections import router as sections_router
from controllers.students import router as students_router

# load backend/.env (explicit path ensures it's found when starting uvicorn from the backend folder)
load_dotenv(Path(__file__).parent / ".env")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create tables on startup (safe — uses IF NOT EXISTS) and ensure columns."""
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        logging.error("Database init failed at startup (continuing): %s", e)
    try:
        ensure_columns()
    except Exception as e:
        logging.error("Column migration failed at startup (continuing): %s", e)
    yield


app = FastAPI(
    title="PhotoSync API",
    description="Backend API for PhotoSync — Test Paper Scanner & Grade Management (Neon PostgreSQL)",
    version="37.1.0",
    lifespan=lifespan,
    contact={"name": "Habibun-najal K. Kayting", "email": "kayting4k@gmail.com"},
)

# CORS — allow all origins for cross-device access during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(exams_router)
app.include_router(results_router)
app.include_router(dashboard_router)
app.include_router(grades_router)
app.include_router(scanner_router)
app.include_router(scan_uploads_router)
app.include_router(email_router)
app.include_router(scoring_rules_router)
app.include_router(academic_terms_router)
app.include_router(attendance_router)
app.include_router(gpa_config_router)
app.include_router(subjects_router)
app.include_router(sections_router)
app.include_router(students_router)

# Serve uploaded scan images statically
uploads_dir = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(uploads_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=uploads_dir), name="uploads")


@app.get("/", tags=["Health"])
def root():
    return {
        "app": "PhotoSync API",
        "version": "37.1.0",
        "database": "Neon PostgreSQL",
        "status": "running",
        "docs": "/docs",
    }