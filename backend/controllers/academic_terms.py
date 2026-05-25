"""
Academic Terms controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.academic_term import AcademicTerm
from models.user import User
from schemas import AcademicTermCreate, AcademicTermUpdate

router = APIRouter(prefix="/academic-terms", tags=["Academic Terms"])


def _serialize(t: AcademicTerm) -> dict:
    return {
        "id": str(t.id),
        "user_id": str(t.user_id),
        "name": t.name,
        "term_type": t.term_type,
        "percentage_weight": t.percentage_weight,
        "start_date": t.start_date.isoformat() if t.start_date else None,
        "end_date": t.end_date.isoformat() if t.end_date else None,
        "is_current": t.is_current,
        "created_at": t.created_at.isoformat() if t.created_at else None,
    }


@router.get("/")
def get_academic_terms(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(AcademicTerm).filter(AcademicTerm.user_id == current_user.id)
    q = q.order_by(AcademicTerm.created_at.desc())
    return [_serialize(t) for t in q.all()]


@router.post("/")
def create_academic_term(
    body: AcademicTermCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # If setting as current, unset any existing current term
    if body.is_current:
        db.query(AcademicTerm).filter(
            AcademicTerm.user_id == current_user.id,
            AcademicTerm.is_current == True,
        ).update({"is_current": False})

    term = AcademicTerm(
        user_id=current_user.id,
        name=body.name,
        term_type=body.term_type,
        percentage_weight=body.percentage_weight,
        start_date=body.start_date,
        end_date=body.end_date,
        is_current=body.is_current,
    )
    db.add(term)
    db.commit()
    db.refresh(term)
    return _serialize(term)


@router.put("/{term_id}")
def update_academic_term(
    term_id: str,
    body: AcademicTermUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    term = db.query(AcademicTerm).filter(
        AcademicTerm.id == term_id, AcademicTerm.user_id == current_user.id
    ).first()
    if not term:
        raise HTTPException(status_code=404, detail="Academic term not found")

    # If setting as current, unset any other current term
    if body.is_current:
        db.query(AcademicTerm).filter(
            AcademicTerm.user_id == current_user.id,
            AcademicTerm.is_current == True,
            AcademicTerm.id != term_id,
        ).update({"is_current": False})

    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(term, key, value)
    db.commit()
    db.refresh(term)
    return _serialize(term)


@router.delete("/{term_id}")
def delete_academic_term(
    term_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    term = db.query(AcademicTerm).filter(
        AcademicTerm.id == term_id, AcademicTerm.user_id == current_user.id
    ).first()
    if not term:
        raise HTTPException(status_code=404, detail="Academic term not found")
    db.delete(term)
    db.commit()
    return {"message": "Academic term deleted"}