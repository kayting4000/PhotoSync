"""
Student Subjects controller — CRUD for student_subjects table (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.student_subject import StudentSubject
from models.user import User
from schemas import StudentSubjectCreate, StudentSubjectUpdate

router = APIRouter(prefix="/student-subjects", tags=["Student Subjects"])


def _serialize(ss: StudentSubject) -> dict:
    return {
        "id": str(ss.id),
        "user_id": str(ss.user_id),
        "student_id": str(ss.student_id),
        "subject_id": str(ss.subject_id),
        "semester": ss.semester,
        "academic_year": ss.academic_year,
        "final_grade": ss.final_grade,
        "grade_equivalent": ss.grade_equivalent,
        "created_at": ss.created_at.isoformat() if ss.created_at else None,
    }


@router.get("/")
def get_student_subjects(
    student_id: Optional[str] = Query(None),
    subject_id: Optional[str] = Query(None),
    semester: Optional[str] = Query(None),
    academic_year: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(StudentSubject).filter(StudentSubject.user_id == current_user.id)
    if student_id:
        q = q.filter(StudentSubject.student_id == student_id)
    if subject_id:
        q = q.filter(StudentSubject.subject_id == subject_id)
    if semester:
        q = q.filter(StudentSubject.semester == semester)
    if academic_year:
        q = q.filter(StudentSubject.academic_year == academic_year)
    q = q.order_by(StudentSubject.created_at.desc())
    return [_serialize(ss) for ss in q.all()]


@router.post("/")
def create_student_subject(
    body: StudentSubjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ss = StudentSubject(
        user_id=current_user.id,
        student_id=body.student_id,
        subject_id=body.subject_id,
        semester=body.semester,
        academic_year=body.academic_year,
        final_grade=body.final_grade,
        grade_equivalent=body.grade_equivalent,
    )
    db.add(ss)
    db.commit()
    db.refresh(ss)
    return _serialize(ss)


@router.put("/{student_subject_id}")
def update_student_subject(
    student_subject_id: str,
    body: StudentSubjectUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ss = db.query(StudentSubject).filter(
        StudentSubject.id == student_subject_id, StudentSubject.user_id == current_user.id
    ).first()
    if not ss:
        raise HTTPException(status_code=404, detail="StudentSubject not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(ss, key, value)
    db.commit()
    db.refresh(ss)
    return _serialize(ss)


@router.delete("/{student_subject_id}")
def delete_student_subject(
    student_subject_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ss = db.query(StudentSubject).filter(
        StudentSubject.id == student_subject_id, StudentSubject.user_id == current_user.id
    ).first()
    if not ss:
        raise HTTPException(status_code=404, detail="StudentSubject not found")
    db.delete(ss)
    db.commit()
    return {"message": "StudentSubject deleted"}