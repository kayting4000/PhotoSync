from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.subject import Subject
from models.user import User

router = APIRouter(prefix="/subjects", tags=["Subjects"])


@router.get("/")
def get_subjects(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    subjects = (
        db.query(Subject)
        .filter(Subject.user_id == current_user.id)
        .all()
    )

    return {
        "items": [
            {
                "id": str(s.id),
                "code": s.code,
                "name": s.name,
                "units": s.units,
            }
            for s in subjects
        ]
    }


@router.post("/")
def create_subject(
    data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    subject = Subject(
        user_id=current_user.id,
        code=data.get("code", ""),
        name=data["name"],
        units=data.get("units", 3),
    )

    db.add(subject)
    db.commit()
    db.refresh(subject)

    return {
        "id": str(subject.id),
        "code": subject.code,
        "name": subject.name,
        "units": subject.units,
    }