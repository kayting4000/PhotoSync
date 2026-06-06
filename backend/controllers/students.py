from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models.student import Student
from controllers.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/students", tags=["Students"])


# -------------------------
# CREATE STUDENT
# -------------------------
@router.post("/")
def create_student(
    data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    student = Student(
        user_id=current_user.id,
        student_id=data["student_id"],
        first_name=data["first_name"],
        middle_initial=data.get("middle_initial"),
        last_name=data["last_name"],
        email=data.get("email"),
        parent_guardian_email=data.get("parent_guardian_email"),
        course=data.get("course"),
        year_level=data.get("year_level"),
        section_id=data["section_id"],
    )

    db.add(student)
    db.commit()
    db.refresh(student)

    return {
        "id": str(student.id),
        "student_id": student.student_id,
        "name": f"{student.first_name} {student.last_name}",
        "section_id": str(student.section_id)
    }


# -------------------------
# GET ALL STUDENTS
# -------------------------
@router.get("/")
def get_students(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    students = db.query(Student).filter(Student.user_id == current_user.id).all()

    return {
        "items": [
            {
                "id": str(s.id),
                "student_id": s.student_id,
                "name": f"{s.first_name} {s.last_name}",
                "section_id": str(s.section_id),
            }
            for s in students
        ]
    }