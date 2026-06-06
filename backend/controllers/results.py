"""
Exam Results controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
import uuid
from uuid import UUID
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.exam_result import ExamResult
from models.user import User
from schemas import ExamResultCreate, ExamResultUpdate

router = APIRouter(prefix="/results", tags=["Results"])


def _assign_grade(percentage: float) -> tuple:
    """Returns (grade_letter, grade_point, remarks) using MSU scale."""
    if percentage >= 96:
        return "1.0", 1.0, "Passed"
    if percentage >= 92:
        return "1.25", 1.25, "Passed"
    if percentage >= 88:
        return "1.5", 1.5, "Passed"
    if percentage >= 84:
        return "1.75", 1.75, "Passed"
    if percentage >= 80:
        return "2.0", 2.0, "Passed"
    if percentage >= 76:
        return "2.25", 2.25, "Passed"
    if percentage >= 72:
        return "2.5", 2.5, "Passed"
    if percentage >= 68:
        return "2.75", 2.75, "Passed"
    if percentage >= 60:
        return "3.0", 3.0, "Passed"
    return "5.0", 5.0, "Failed"


def _serialize(r: ExamResult) -> dict:
    return {
        "id": str(r.id),
        "user_id": str(r.user_id),
        "student_id": str(r.student_id),
        "exam_id": str(r.exam_id),
        "correct_answers": r.correct_answers,
        "total_score": r.total_score,
        "percentage": r.percentage,
        "grade": r.grade,
        "grade_point": r.grade_point,
        "remarks": r.remarks,
        "scanned_image_url": r.scanned_image_url,
        "created_at": r.created_at.isoformat() if r.created_at else None,
    }


@router.get("/")
def get_results(
    student_id: Optional[str] = Query(None),
    exam_id: Optional[str] = Query(None),
    skip: int = Query(0, ge=0, alias="offset"),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(ExamResult).filter(ExamResult.user_id == current_user.id)
    if student_id:
        try:
            q = q.filter(ExamResult.student_id == uuid.UUID(student_id))
        except ValueError:
            q = q.filter(ExamResult.student_id == student_id)
    if exam_id:
        try:
            q = q.filter(ExamResult.exam_id == uuid.UUID(exam_id))
        except ValueError:
            q = q.filter(ExamResult.exam_id == exam_id)
    total = q.count()
    q = q.order_by(ExamResult.created_at.desc()).offset(skip).limit(limit)
    return {
        "items": [_serialize(r) for r in q.all()],
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/")
def create_result(
    body: ExamResultCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    data = body.model_dump()
    if data.get("percentage") is not None and not data.get("grade"):
        grade, gp, remarks = _assign_grade(data["percentage"])
        data["grade"] = grade
        data["grade_point"] = gp
        data.setdefault("remarks", remarks)

    result = ExamResult(
        user_id=current_user.id,
        student_id=UUID(data["student_id"]) if isinstance(data["student_id"], str) and len(data["student_id"]) == 36 else data["student_id"],
        exam_id=UUID(data["exam_id"]) if isinstance(data["exam_id"], str) and len(data["exam_id"]) == 36 else data["exam_id"],
        correct_answers=data["correct_answers"],
        total_score=data["total_score"],
        percentage=data.get("percentage"),
        grade=data.get("grade"),
        grade_point=data.get("grade_point"),
        remarks=data.get("remarks"),
        scanned_image_url=data.get("scanned_image_url"),
    )
    db.add(result)
    db.commit()
    db.refresh(result)
    return _serialize(result)


@router.put("/{result_id}")
def update_result(
    result_id: str,
    body: ExamResultUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = db.query(ExamResult).filter(
        ExamResult.id == result_id, ExamResult.user_id == current_user.id
    ).first()
    if not result:
        raise HTTPException(status_code=404, detail="Result not found")

    update_data = body.model_dump(exclude_unset=True)
    if update_data.get("percentage") is not None and "grade" not in update_data:
        grade, gp, remarks = _assign_grade(update_data["percentage"])
        update_data["grade"] = grade
        update_data["grade_point"] = gp
        update_data.setdefault("remarks", remarks)

    for key, value in update_data.items():
        setattr(result, key, value)
    db.commit()
    db.refresh(result)
    return _serialize(result)


@router.delete("/{result_id}")
def delete_result(
    result_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = db.query(ExamResult).filter(
        ExamResult.id == result_id, ExamResult.user_id == current_user.id
    ).first()
    if not result:
        raise HTTPException(status_code=404, detail="Result not found")
    db.delete(result)
    db.commit()
    return {"message": "Result deleted"}