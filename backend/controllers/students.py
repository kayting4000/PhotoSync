"""
Students controller — CRUD operations via SQLAlchemy ORM (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_

from database import get_db
from controllers.auth import get_current_user
from models.student import Student
from models.user import User
from schemas import StudentCreate, StudentUpdate

router = APIRouter(prefix="/students", tags=["Students"])


def _serialize(s: Student) -> dict:
    return {
        "id": str(s.id),
        "user_id": str(s.user_id),
        "student_id": s.student_id,
        "first_name": s.first_name,
        "last_name": s.last_name,
        "email": s.email,
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
            )
        )
    q = q.order_by(Student.created_at.desc())
    return [_serialize(s) for s in q.all()]


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
        last_name=body.last_name,
        email=body.email,
        course=body.course,
        year_level=body.year_level,
        section_id=body.section_id,
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