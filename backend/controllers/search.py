"""
Search and filter controller for students, grades, and subjects.
Provides comprehensive search capabilities with pagination.
"""
from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import Optional
from pydantic import BaseModel

from database import get_db
from controllers.auth import get_current_user
from models.user import User
from models.student import Student
from models.exam_result import ExamResult
from models.subject import Subject
from models.exam import Exam

router = APIRouter(prefix="/search", tags=["Search"])


class SearchResponse(BaseModel):
    total: int
    page: int
    page_size: int
    results: list


@router.get("/students")
async def search_students(
    q: Optional[str] = Query(None, min_length=1, description="Search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    sort_by: Optional[str] = Query("name", regex="^(name|id|course|year)$"),
    sort_order: Optional[str] = Query("asc", regex="^(asc|desc)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Search students by name, ID, course, or year level with pagination."""
    
    query = db.query(Student).filter(Student.user_id == current_user.id)
    
    # Apply search filter
    if q:
        query = query.filter(
            or_(
                Student.first_name.ilike(f"%{q}%"),
                Student.last_name.ilike(f"%{q}%"),
                Student.student_id.ilike(f"%{q}%"),
                Student.course.ilike(f"%{q}%"),
            )
        )
    
    # Get total count
    total = query.count()
    
    # Apply sorting
    if sort_by == "name":
        query = query.order_by(
            Student.first_name.asc() if sort_order == "asc" else Student.first_name.desc()
        )
    elif sort_by == "id":
        query = query.order_by(
            Student.student_id.asc() if sort_order == "asc" else Student.student_id.desc()
        )
    elif sort_by == "course":
        query = query.order_by(
            Student.course.asc() if sort_order == "asc" else Student.course.desc()
        )
    elif sort_by == "year":
        query = query.order_by(
            Student.year_level.asc() if sort_order == "asc" else Student.year_level.desc()
        )
    
    # Apply pagination
    skip = (page - 1) * page_size
    students = query.offset(skip).limit(page_size).all()
    
    results = [
        {
            "id": str(s.id),
            "first_name": s.first_name,
            "last_name": s.last_name,
            "student_id": s.student_id,
            "email": s.email,
            "course": s.course,
            "year_level": s.year_level,
        }
        for s in students
    ]
    
    return {
        "total": total,
        "page": page,
        "page_size": page_size,
        "results": results,
    }


@router.get("/grades")
async def search_grades(
    student_id: Optional[str] = Query(None),
    subject_code: Optional[str] = Query(None),
    min_percentage: Optional[float] = Query(None, ge=0, le=100),
    max_percentage: Optional[float] = Query(None, ge=0, le=100),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    sort_by: Optional[str] = Query("date", regex="^(date|percentage|grade)$"),
    sort_order: Optional[str] = Query("desc", regex="^(asc|desc)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Search grades with filters for student, subject, and percentage range."""
    
    query = db.query(ExamResult).filter(ExamResult.user_id == current_user.id)
    
    # Filter by student
    if student_id:
        query = query.filter(ExamResult.student_id == student_id)
    
    # Filter by subject code
    if subject_code:
        query = query.join(Exam).join(Subject).filter(
            Subject.code.ilike(f"%{subject_code}%")
        )
    
    # Filter by percentage range
    if min_percentage is not None:
        query = query.filter(ExamResult.percentage >= min_percentage)
    if max_percentage is not None:
        query = query.filter(ExamResult.percentage <= max_percentage)
    
    # Get total count
    total = query.count()
    
    # Apply sorting
    if sort_by == "date":
        query = query.order_by(
            ExamResult.created_at.asc() if sort_order == "asc" else ExamResult.created_at.desc()
        )
    elif sort_by == "percentage":
        query = query.order_by(
            ExamResult.percentage.asc() if sort_order == "asc" else ExamResult.percentage.desc()
        )
    elif sort_by == "grade":
        query = query.order_by(
            ExamResult.grade.asc() if sort_order == "asc" else ExamResult.grade.desc()
        )
    
    # Apply pagination
    skip = (page - 1) * page_size
    results_data = query.offset(skip).limit(page_size).all()
    
    results = [
        {
            "id": str(r.id),
            "student_id": str(r.student_id),
            "exam_name": r.exam.name if r.exam else "Unknown",
            "subject_code": r.exam.subject.code if r.exam and r.exam.subject else "Unknown",
            "subject_name": r.exam.subject.name if r.exam and r.exam.subject else "Unknown",
            "percentage": r.percentage,
            "grade": r.grade,
            "grade_point": r.grade_point,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        }
        for r in results_data
    ]
    
    return {
        "total": total,
        "page": page,
        "page_size": page_size,
        "results": results,
    }


@router.get("/subjects")
async def search_subjects(
    q: Optional[str] = Query(None, min_length=1),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    sort_by: Optional[str] = Query("name", regex="^(name|code|units)$"),
    sort_order: Optional[str] = Query("asc", regex="^(asc|desc)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Search subjects by name or code with pagination."""
    
    query = db.query(Subject).filter(Subject.user_id == current_user.id)
    
    # Apply search filter
    if q:
        query = query.filter(
            or_(
                Subject.name.ilike(f"%{q}%"),
                Subject.code.ilike(f"%{q}%"),
            )
        )
    
    # Get total count
    total = query.count()
    
    # Apply sorting
    if sort_by == "name":
        query = query.order_by(
            Subject.name.asc() if sort_order == "asc" else Subject.name.desc()
        )
    elif sort_by == "code":
        query = query.order_by(
            Subject.code.asc() if sort_order == "asc" else Subject.code.desc()
        )
    elif sort_by == "units":
        query = query.order_by(
            Subject.units.asc() if sort_order == "asc" else Subject.units.desc()
        )
    
    # Apply pagination
    skip = (page - 1) * page_size
    subjects = query.offset(skip).limit(page_size).all()
    
    results = [
        {
            "id": str(s.id),
            "code": s.code,
            "name": s.name,
            "units": s.units,
            "description": s.description,
        }
        for s in subjects
    ]
    
    return {
        "total": total,
        "page": page,
        "page_size": page_size,
        "results": results,
    }
