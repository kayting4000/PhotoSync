"""
Dashboard controller — aggregate counts via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.student import Student
from models.subject import Subject
from models.exam import Exam
from models.exam_result import ExamResult
from models.user import User

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {
        "total_students": db.query(Student).filter(Student.user_id == current_user.id).count(),
        "total_subjects": db.query(Subject).filter(Subject.user_id == current_user.id).count(),
        "total_exams": db.query(Exam).filter(Exam.user_id == current_user.id).count(),
        "total_results": db.query(ExamResult).filter(ExamResult.user_id == current_user.id).count(),
    }