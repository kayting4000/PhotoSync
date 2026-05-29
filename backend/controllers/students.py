"""
Students controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
import uuid
from fastapi import APIRouter, HTTPException, Query, Depends, Path
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_

from database import get_db
from controllers.auth import get_current_user
from models import Student, Section, User
from schemas import StudentCreate, StudentUpdate

router = APIRouter(prefix="/students", tags=["Students"])


def _serialize(s: Student) -> dict:
    return {
        "id": str(s.id),
        "user_id": str(s.user_id),
        "student_id": s.student_id,
        "first_name": s.first_name,
        "middle_initial": s.middle_initial,
        "last_name": s.last_name,
        "email": s.email,
        "parent_guardian_email": s.parent_guardian_email,
        "course": s.course,
        "year_level": s.year_level,
        "section_id": str(s.section_id) if s.section_id else None,
        "created_at": s.created_at.isoformat() if s.created_at else None,
        "updated_at": s.updated_at.isoformat() if s.updated_at else None,
    }


@router.get("/")
def get_students(
    course: Optional[str] = Query(None),
    year_level: Optional[int] = Query(None),
    section_id: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    skip: int = Query(0, ge=0, alias="offset"),
    limit: int = Query(50, ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Student).filter(Student.user_id == current_user.id)
    if course:
        q = q.filter(Student.course == course)
    if year_level is not None:
        q = q.filter(Student.year_level == year_level)
    if section_id:
        q = q.filter(Student.section_id == section_id)
    if search:
        q = q.filter(
            or_(
                Student.first_name.ilike(f"%{search}%"),
                Student.last_name.ilike(f"%{search}%"),
                Student.student_id.ilike(f"%{search}%"),
            )
        )
    total = q.count()
    q = q.order_by(Student.created_at.desc()).offset(skip).limit(limit)
    return {
        "items": [_serialize(s) for s in q.all()],
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/")
def create_student(
    body: StudentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    student = Student(
        user_id=current_user.id,
        student_id=body.student_id,
        first_name=body.first_name,
        middle_initial=body.middle_initial,
        last_name=body.last_name,
        email=body.email,
        parent_guardian_email=body.parent_guardian_email,
        course=body.course,
        year_level=body.year_level,
        section_id=uuid.UUID(body.section_id) if body.section_id else None,
    )
    db.add(student)
    db.commit()
    db.refresh(student)
    return _serialize(student)


@router.put("/{student_id}")
def update_student(
    student_id: str,
    body: StudentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    student = db.query(Student).filter(
        Student.id == student_id, Student.user_id == current_user.id
    ).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(student, key, value)
    db.commit()
    db.refresh(student)
    return _serialize(student)


@router.delete("/{student_id}")
def delete_student(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    student = db.query(Student).filter(
        Student.id == student_id, Student.user_id == current_user.id
    ).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    db.delete(student)
    db.commit()
    return {"message": "Student deleted"}


# The POST /students/ endpoint is defined above by the first create_student.
# The duplicate create_student below was removed because it:
#   1. Overwrote the proper POST /students/ endpoint
#   2. Used incorrect model fields (Student has no "name" column)
#   3. Used int instead of UUID for section_id
