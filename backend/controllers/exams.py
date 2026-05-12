"""
Exams controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.exam import Exam
from models.user import User
from schemas import ExamCreate, ExamUpdate

router = APIRouter(prefix="/exams", tags=["Exams"])


def _serialize(e: Exam) -> dict:
    return {
        "id": str(e.id),
        "user_id": str(e.user_id),
        "subject_id": str(e.subject_id),
        "name": e.name,
        "exam_type": e.exam_type,
        "total_items": e.total_items,
        "points_per_item": e.points_per_item,
        "passing_score": e.passing_score,
        "created_at": e.created_at.isoformat() if e.created_at else None,
    }


@router.get("/")
def get_exams(
    subject_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Exam).filter(Exam.user_id == current_user.id)
    if subject_id:
        q = q.filter(Exam.subject_id == subject_id)
    q = q.order_by(Exam.created_at.desc())
    return [_serialize(e) for e in q.all()]


@router.post("/")
def create_exam(
    body: ExamCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exam = Exam(
        user_id=current_user.id,
        subject_id=body.subject_id,
        name=body.name,
        exam_type=body.exam_type,
        total_items=body.total_items,
        points_per_item=body.points_per_item,
        passing_score=body.passing_score,
    )
    db.add(exam)
    db.commit()
    db.refresh(exam)
    return _serialize(exam)


@router.put("/{exam_id}")
def update_exam(
    exam_id: str,
    body: ExamUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exam = db.query(Exam).filter(
        Exam.id == exam_id, Exam.user_id == current_user.id
    ).first()
    if not exam:
        raise HTTPException(status_code=404, detail="Exam not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(exam, key, value)
    db.commit()
    db.refresh(exam)
    return _serialize(exam)


@router.delete("/{exam_id}")
def delete_exam(
    exam_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exam = db.query(Exam).filter(
        Exam.id == exam_id, Exam.user_id == current_user.id
    ).first()
    if not exam:
        raise HTTPException(status_code=404, detail="Exam not found")
    db.delete(exam)
    db.commit()
    return {"message": "Exam deleted"}