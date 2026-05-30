"""
Subjects controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.subject import Subject
from models.user import User
from schemas import SubjectCreate, SubjectUpdate

router = APIRouter(prefix="/subjects", tags=["Subjects"])


def _serialize(s: Subject) -> dict:
    return {
        "id": str(s.id),
        "user_id": str(s.user_id),
        "code": s.code,
        "name": s.name,
        "units": s.units,
        "created_at": s.created_at.isoformat() if s.created_at else None,
    }


@router.get("/")
def get_subjects(
    skip: int = Query(0, ge=0, alias="offset"),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Subject).filter(Subject.user_id == current_user.id)
    total = q.count()
    subjects = q.order_by(Subject.created_at.desc()).offset(skip).limit(limit).all()
    return {
        "items": [_serialize(s) for s in subjects],
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/")
def create_subject(
    body: SubjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    name = body.name
    if not name:
        raise HTTPException(status_code=400, detail="name is required")
    subject = Subject(
        user_id=current_user.id,
        code=body.code,
        name=name,
        units=body.units,
    )
    db.add(subject)
    try:
        db.commit()
        db.refresh(subject)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    return _serialize(subject)


@router.put("/{subject_id}")
def update_subject(
    subject_id: str,
    body: SubjectUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    subject = db.query(Subject).filter(
        Subject.id == subject_id, Subject.user_id == current_user.id
    ).first()
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(subject, key, value)
    db.commit()
    db.refresh(subject)
    return _serialize(subject)


@router.delete("/{subject_id}")
def delete_subject(
    subject_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    subject = db.query(Subject).filter(
        Subject.id == subject_id, Subject.user_id == current_user.id
    ).first()
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")
    db.delete(subject)
    db.commit()
    return {"message": "Subject deleted"}
