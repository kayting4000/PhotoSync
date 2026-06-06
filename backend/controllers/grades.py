"""
Grades / GPA controller — computes GPA using MSU-Tawi-Tawi formula.
Uses SQLAlchemy joins instead of Supabase PostgREST nested selects.
Also supports weighted term grades (preliminary, mid-semester, final).
"""
from fastapi import APIRouter, Query, Depends
from typing import Optional, Dict
from sqlalchemy.orm import Session, joinedload

from database import get_db
from controllers.auth import get_current_user
from models.exam_result import ExamResult
from models.exam import Exam
from models.academic_term import AcademicTerm
from models.subject import Subject
from models.user import User

router = APIRouter(prefix="/gpa", tags=["Grades"])


def _interpret(gpa: float) -> str:
    if gpa <= 1.25:
        return "Excellent"
    if gpa <= 1.75:
        return "Very Good"
    if gpa <= 2.25:
        return "Good"
    if gpa <= 2.75:
        return "Satisfactory"
    if gpa <= 3.0:
        return "Passing"
    return "Failed"


@router.get("/")
def get_gpa(
    student_id: Optional[str] = Query(None),
    term_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = (
        db.query(ExamResult)
        .options(joinedload(ExamResult.exam).joinedload(Exam.subject))
        .filter(ExamResult.user_id == current_user.id)
    )
    if student_id:
        q = q.filter(ExamResult.student_id == student_id)
    if term_id:
        q = q.filter(ExamResult.exam.has(Exam.term_id == term_id))
    q = q.order_by(ExamResult.created_at.desc())

    results = q.all()
    if not results:
        return {"gpa": None, "total_units": 0, "subjects_counted": 0}

    weighted_sum = 0.0
    total_units = 0

    for r in results:
        gp = r.grade_point
        if gp is None:
            continue
        try:
            units = r.exam.subject.units if r.exam and r.exam.subject else 3
        except Exception:
            units = 3

        weighted_sum += gp * units
        total_units += units

    if total_units == 0:
        return {"gpa": None, "total_units": 0, "subjects_counted": len(results)}

    gpa = round(weighted_sum / total_units, 4)
    return {
        "gpa": gpa,
        "total_units": total_units,
        "subjects_counted": len(results),
        "interpretation": _interpret(gpa),
    }


@router.get("/weighted/")
def get_weighted_term_grades(
    student_id: Optional[str] = Query(None),
    subject_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Calculate final grade as weighted average of terms.
    Each term (preliminary, mid-semester, final) has a percentage_weight.
    Final Grade = sum(term_score * percentage_weight / 100)
    """
    q = (
        db.query(ExamResult)
        .options(
            joinedload(ExamResult.exam)
            .joinedload(Exam.term)
        )
        .filter(ExamResult.user_id == current_user.id)
    )
    if student_id:
        q = q.filter(ExamResult.student_id == student_id)
    if subject_id:
        q = q.filter(ExamResult.exam.has(Exam.subject_id == subject_id))
    
    results = q.all()
    if not results:
        return {
            "final_grade": None,
            "term_scores": {},
            "total_weight": 0,
            "message": "No exam results found"
        }

    # Group results by term
    term_scores: Dict[str, Dict] = {}
    
    for result in results:
        if not result.exam or not result.exam.term:
            continue
        
        term = result.exam.term
        term_id = str(term.id)
        
        if term_id not in term_scores:
            term_scores[term_id] = {
                "term_id": term_id,
                "term_name": term.name,
                "term_type": term.term_type,
                "percentage_weight": term.percentage_weight,
                "scores": [],
            }
        
        # Collect percentage score for each component
        if result.percentage is not None:
            term_scores[term_id]["scores"].append(result.percentage)
    
    # Calculate average for each term
    term_averages = {}
    total_weight = 0
    weighted_sum = 0.0
    
    for term_id, term_data in term_scores.items():
        if term_data["scores"]:
            avg_score = sum(term_data["scores"]) / len(term_data["scores"])
            term_data["average_score"] = round(avg_score, 2)
            term_averages[term_id] = term_data
            
            # Add to weighted sum
            weight = term_data["percentage_weight"]
            weighted_sum += avg_score * (weight / 100)
            total_weight += weight
    
    final_grade = None
    if total_weight > 0:
        final_grade = round(weighted_sum, 2)
    
    return {
        "final_grade": final_grade,
        "term_scores": term_averages,
        "total_weight": total_weight,
        "calculation_method": "weighted_average",
    }