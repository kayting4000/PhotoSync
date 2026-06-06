"""
Sections controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends, Path
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models import Section, Subject
from models.user import User
from schemas import SectionCreate, SectionUpdate

router = APIRouter(prefix="/sections", tags=["Sections"])


def _serialize(s: Section) -> dict:
    return {
        "id": str(s.id),
        "user_id": str(s.user_id),
        "subject_id": str(s.subject_id),
        "section_label": s.section_label,
        "room_number": s.room_number,
        "created_at": s.created_at.isoformat() if s.created_at else None,
    }


@router.get("/")
def get_sections(
    subject_id: Optional[str] = Query(None),
    section_label: Optional[str] = Query(None),
    skip: int = Query(0, ge=0, alias="offset"),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Section).filter(Section.user_id == current_user.id)
    if subject_id:
        q = q.filter(Section.subject_id == subject_id)
    if section_label:
        q = q.filter(Section.section_label == section_label)
    total = q.count()
    q = q.order_by(Section.created_at.desc()).offset(skip).limit(limit)
    return {
        "items": [_serialize(s) for s in q.all()],
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/")
def create_section(
    body: SectionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    section = Section(
        user_id=current_user.id,
        subject_id=body.subject_id,
        section_label=body.section_label,
        room_number=body.room_number,
    )
    db.add(section)
    db.commit()
    db.refresh(section)
    return _serialize(section)


@router.put("/{section_id}")
def update_section(
    section_id: str,
    body: SectionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    section = db.query(Section).filter(
        Section.id == section_id, Section.user_id == current_user.id
    ).first()
    if not section:
        raise HTTPException(status_code=404, detail="Section not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(section, key, value)
    db.commit()
    db.refresh(section)
    return _serialize(section)


@router.delete("/{section_id}")
def delete_section(
    section_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    section = db.query(Section).filter(
        Section.id == section_id, Section.user_id == current_user.id
    ).first()
    if not section:
        raise HTTPException(status_code=404, detail="Section not found")
    db.delete(section)
    db.commit()
    return {"message": "Section deleted"}


@router.post("/subjects/{subject_id}/sections")
def create_section(
    subject_id: int = Path(...),
    payload: dict = None,
    db: Session = Depends(get_db),
):
    payload = payload or {}
    name = payload.get("name")
    if not name:
        raise HTTPException(status_code=400, detail="name is required")
    subject = db.get(Subject, subject_id)
    if not subject:
        raise HTTPException(status_code=404, detail="subject not found")
    section = Section(name=name, subject_id=subject_id)
    db.add(section)
    try:
        db.commit()
        db.refresh(section)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    return {"success": True, "section": {"id": section.id, "name": section.name, "subject_id": subject_id}}