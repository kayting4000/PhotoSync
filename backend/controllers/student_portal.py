"""
Student Portal controller — read-only endpoints for student users.
All endpoints require the 'student' role and derive the student record
from the authenticated user's email.
"""
import uuid
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import require_role
from models.user import User
from models.student import Student
from models.subject import Subject
from models.exam import Exam
from models.exam_result import ExamResult
from models.attendance import Attendance
from models.section import Section

router = APIRouter(prefix="/portal", tags=["Student Portal"])


def _get_student_from_user(db: Session, user: User) -> Student:
    """Find the Student record linked to the authenticated user via email."""
    student = db.query(Student).filter(
        Student.email == user.email
    ).first()
    if not student:
        raise HTTPException(
            status_code=404,
            detail="No student record found for your account. Contact your teacher.",
        )
    return student


# ─── Dashboard ────────────────────────────────────────────────────────────


@router.get("/dashboard")
def portal_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get student dashboard summary: subjects, exams, attendance rate, GPA."""
    student = _get_student_from_user(db, current_user)

    # Count subjects linked to this student
    from models.student_subject import StudentSubject
    subject_count = db.query(StudentSubject).filter(
        StudentSubject.student_id == student.id
    ).count()

    # Count exams (total across all subjects)
    exam_count = db.query(Exam).filter(
        Exam.user_id == student.user_id
    ).count()

    # Attendance rate
    total_attendance = db.query(Attendance).filter(
        Attendance.student_id == student.id
    ).count()
    present_attendance = db.query(Attendance).filter(
        Attendance.student_id == student.id,
        Attendance.status == "present",
    ).count()
    attendance_rate = (present_attendance / total_attendance * 100) if total_attendance > 0 else 0.0

    # GPA from exam results
    from sqlalchemy import func
    avg_result = db.query(func.avg(ExamResult.score)).filter(
        ExamResult.student_id == student.id
    ).scalar()
    gpa = round(float(avg_result) / 20.0, 2) if avg_result else 0.0

    return {
        "total_subjects": subject_count,
        "total_exams": exam_count,
        "attendance_rate": round(attendance_rate, 1),
        "current_gpa": gpa,
    }


# ─── Grades ────────────────────────────────────────────────────────────────


@router.get("/grades")
def portal_grades(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get all grades for the authenticated student."""
    student = _get_student_from_user(db, current_user)

    results = db.query(ExamResult).filter(
        ExamResult.student_id == student.id
    ).all()

    grades = []
    for r in results:
        exam = db.query(Exam).filter(Exam.id == r.exam_id).first()
        if not exam:
            continue
        subject = db.query(Subject).filter(Subject.id == exam.subject_id).first()
        if not subject:
            continue

        percentage = (r.score / exam.total_items * 100) if exam.total_items > 0 else 0
        grade = _compute_grade(percentage)
        grade_point = _compute_grade_point(percentage)
        remarks = "Passed" if percentage >= 60 else "Failed"

        grades.append({
            "exam_name": exam.name,
            "subject_code": subject.code,
            "subject_name": subject.name,
            "percentage": round(percentage, 1),
            "grade": grade,
            "grade_point": grade_point,
            "remarks": remarks,
        })

    return {"items": grades}


@router.get("/grades/summary")
def portal_grade_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get grade summary grouped by subject."""
    student = _get_student_from_user(db, current_user)

    from models.student_subject import StudentSubject
    enrollments = db.query(StudentSubject).filter(
        StudentSubject.student_id == student.id
    ).all()

    summaries = []
    for enrollment in enrollments:
        subject = db.query(Subject).filter(Subject.id == enrollment.subject_id).first()
        if not subject:
            continue

        results = db.query(ExamResult).filter(
            ExamResult.student_id == student.id,
            ExamResult.exam_id.in_(
                db.query(Exam.id).filter(Exam.subject_id == subject.id)
            ),
        ).all()

        if not results:
            continue

        avg_percentage = sum(
            (r.score / (db.query(Exam).filter(Exam.id == r.exam_id).first().total_items * 100))
            if db.query(Exam).filter(Exam.id == r.exam_id).first() and db.query(Exam).filter(Exam.id == r.exam_id).first().total_items > 0
            else 0
            for r in results
        ) / len(results) * 100 if results else 0

        grade = _compute_grade(avg_percentage)
        grade_point = _compute_grade_point(avg_percentage)
        remarks = "Passed" if avg_percentage >= 60 else "Failed"

        summaries.append({
            "subject_code": subject.code,
            "subject_name": subject.name,
            "units": subject.units,
            "grade": grade,
            "grade_point": grade_point,
            "remarks": remarks,
        })

    return {"items": summaries}


# ─── Attendance ────────────────────────────────────────────────────────────


@router.get("/attendance")
def portal_attendance(
    subject_id: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get attendance records for the authenticated student."""
    student = _get_student_from_user(db, current_user)

    q = db.query(Attendance).filter(Attendance.student_id == student.id)
    if subject_id:
        try:
            q = q.filter(Attendance.subject_id == uuid.UUID(subject_id))
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid subject_id format")

    records = q.order_by(Attendance.year.desc(), Attendance.month.desc(), Attendance.day.desc()).all()

    items = []
    for a in records:
        subject = db.query(Subject).filter(Subject.id == a.subject_id).first()
        items.append({
            "subject_name": subject.name if subject else "Unknown",
            "subject_code": subject.code if subject else "N/A",
            "year": a.year,
            "month": a.month,
            "day": a.day,
            "status": a.status,
        })

    return {"items": items}


# ─── Exams ──────────────────────────────────────────────────────────────────


@router.get("/exams")
def portal_exams(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get exams for subjects the student is enrolled in."""
    student = _get_student_from_user(db, current_user)

    from models.student_subject import StudentSubject
    enrollments = db.query(StudentSubject).filter(
        StudentSubject.student_id == student.id
    ).all()

    subject_ids = [e.subject_id for e in enrollments]
    if not subject_ids:
        return {"items": []}

    exams = db.query(Exam).filter(Exam.subject_id.in_(subject_ids)).all()

    items = []
    for e in exams:
        subject = db.query(Subject).filter(Subject.id == e.subject_id).first()
        items.append({
            "id": str(e.id),
            "name": e.name,
            "subject_code": subject.code if subject else "N/A",
            "subject_name": subject.name if subject else "Unknown",
            "total_items": e.total_items,
            "component_type": e.component_type,
        })

    return {"items": items}


# ─── Profile ────────────────────────────────────────────────────────────────


@router.get("/profile")
def portal_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("student")),
):
    """Get the authenticated student's profile info."""
    student = _get_student_from_user(db, current_user)

    section_label = None
    if student.section_id:
        section = db.query(Section).filter(Section.id == student.section_id).first()
        section_label = section.section_label if section else None

    return {
        "id": str(student.id),
        "student_id": student.student_id,
        "first_name": student.first_name,
        "last_name": student.last_name,
        "email": student.email,
        "course": student.course,
        "year_level": student.year_level,
        "section_label": section_label,
    }


# ─── Helpers ────────────────────────────────────────────────────────────────


def _compute_grade(percentage: float) -> str:
    if percentage >= 97:
        return "A+"
    elif percentage >= 93:
        return "A"
    elif percentage >= 90:
        return "A-"
    elif percentage >= 87:
        return "B+"
    elif percentage >= 83:
        return "B"
    elif percentage >= 80:
        return "B-"
    elif percentage >= 77:
        return "C+"
    elif percentage >= 73:
        return "C"
    elif percentage >= 70:
        return "C-"
    elif percentage >= 67:
        return "D+"
    elif percentage >= 60:
        return "D"
    else:
        return "F"


def _compute_grade_point(percentage: float) -> float:
    if percentage >= 97:
        return 4.0
    elif percentage >= 93:
        return 4.0
    elif percentage >= 90:
        return 3.7
    elif percentage >= 87:
        return 3.3
    elif percentage >= 83:
        return 3.0
    elif percentage >= 80:
        return 2.7
    elif percentage >= 77:
        return 2.3
    elif percentage >= 73:
        return 2.0
    elif percentage >= 70:
        return 1.7
    elif percentage >= 67:
        return 1.3
    elif percentage >= 60:
        return 1.0
    else:
        return 0.0