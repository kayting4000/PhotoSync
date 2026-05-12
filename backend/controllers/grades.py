"""
Grades / GPA controller — computes GPA using MSU-Tawi-Tawi formula.
Uses SQLAlchemy joins instead of Supabase PostgREST nested selects.
"""
from fastapi import APIRouter, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session, joinedload

from database import get_db
from controllers.auth import get_current_user
from models.exam_result import ExamResult
from models.exam import Exam
from models.subject import Subject
from models.user import User

router = APIRouter(prefix="/gpa", tags=["Grades"])


def _interpret(gpa: float) -> str:
    if gpa <= 1.25:
        return "Excellent"
    if gpa <= 1.75:
        return "Very Good"
    if gpa <= 2.25:
        return "Good"
    if gpa <= 2.75:
        return "Satisfactory"
    if gpa <= 3.0:
        return "Passing"
    return "Failed"


@router.get("/")
def get_gpa(
    student_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = (
        db.query(ExamResult)
        .options(joinedload(ExamResult.exam).joinedload(Exam.subject))
        .filter(ExamResult.user_id == current_user.id)
    )
    if student_id:
        q = q.filter(ExamResult.student_id == student_id)
    q = q.order_by(ExamResult.created_at.desc())

    results = q.all()
    if not results:
        return {"gpa": None, "total_units": 0, "subjects_counted": 0}

    weighted_sum = 0.0
    total_units = 0

    for r in results:
        gp = r.grade_point
        if gp is None:
            continue
        try:
            units = r.exam.subject.units if r.exam and r.exam.subject else 3
        except Exception:
            units = 3

        weighted_sum += gp * units
        total_units += units

    if total_units == 0:
        return {"gpa": None, "total_units": 0, "subjects_counted": len(results)}

    gpa = round(weighted_sum / total_units, 4)
    return {
        "gpa": gpa,
        "total_units": total_units,
        "subjects_counted": len(results),
        "interpretation": _interpret(gpa),
    }