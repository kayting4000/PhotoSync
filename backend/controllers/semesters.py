"""
Semesters and Variables controller — Full CRUD for folder-based semester system
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models import Semester, SemesterVariable
from models.user import User
from schemas import SemesterCreate, SemesterUpdate, SemesterVariableCreate, SemesterVariableUpdate

router = APIRouter(prefix="/semesters", tags=["Semesters"])
variable_router = APIRouter(prefix="/variables", tags=["Variables"])


def _serialize_semester(s: Semester) -> dict:
    return {
        "id": str(s.id),
        "student_id": str(s.student_id),
        "user_id": str(s.user_id),
        "term": s.term,
        "created_at": s.created_at.isoformat() if s.created_at else None,
    }


def _serialize_variable(v: SemesterVariable) -> dict:
    return {
        "id": str(v.id),
        "semester_id": str(v.semester_id),
        "user_id": str(v.user_id),
        "name": v.name,
        "score": v.score,
        "total_score": v.total_score,
        "weight": v.weight,
        "created_at": v.created_at.isoformat() if v.created_at else None,
    }


# ─────────────────────────────────────────────────────────────────────────────
# SEMESTERS CRUD
# ─────────────────────────────────────────────────────────────────────────────

@router.get("/")
def get_semesters(
    student_id: Optional[str] = Query(None),
    term: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(Semester).filter(Semester.user_id == current_user.id)
    if student_id:
        q = q.filter(Semester.student_id == student_id)
    if term:
        q = q.filter(Semester.term == term)
    semesters = q.order_by(Semester.created_at.desc()).all()
    return {"items": [_serialize_semester(s) for s in semesters]}


@router.post("/")
def create_semester(
    body: SemesterCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    semester = Semester(
        user_id=current_user.id,
        student_id=body.student_id,
        term=body.term,
    )
    db.add(semester)
    db.commit()
    db.refresh(semester)
    return _serialize_semester(semester)


@router.put("/{semester_id}")
def update_semester(
    semester_id: str,
    body: SemesterUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    semester = db.query(Semester).filter(
        Semester.id == semester_id, Semester.user_id == current_user.id
    ).first()
    if not semester:
        raise HTTPException(status_code=404, detail="Semester not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(semester, key, value)
    db.commit()
    db.refresh(semester)
    return _serialize_semester(semester)


@router.delete("/{semester_id}")
def delete_semester(
    semester_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    semester = db.query(Semester).filter(
        Semester.id == semester_id, Semester.user_id == current_user.id
    ).first()
    if not semester:
        raise HTTPException(status_code=404, detail="Semester not found")
    db.delete(semester)
    db.commit()
    return {"message": "Semester deleted"}


# ─────────────────────────────────────────────────────────────────────────────
# VARIABLES CRUD
# ─────────────────────────────────────────────────────────────────────────────

@variable_router.get("/")
def get_variables(
    semester_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(SemesterVariable).filter(SemesterVariable.user_id == current_user.id)
    if semester_id:
        q = q.filter(SemesterVariable.semester_id == semester_id)
    variables = q.order_by(SemesterVariable.created_at.asc()).all()
    return {"items": [_serialize_variable(v) for v in variables]}


@variable_router.post("/")
def create_variable(
    body: SemesterVariableCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    variable = SemesterVariable(
        user_id=current_user.id,
        semester_id=body.semester_id,
        name=body.name,
        score=body.score,
        total_score=body.total_score,
        weight=body.weight,
    )
    db.add(variable)
    db.commit()
    db.refresh(variable)
    return _serialize_variable(variable)


@variable_router.put("/{variable_id}")
def update_variable(
    variable_id: str,
    body: SemesterVariableUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    variable = db.query(SemesterVariable).filter(
        SemesterVariable.id == variable_id, SemesterVariable.user_id == current_user.id
    ).first()
    if not variable:
        raise HTTPException(status_code=404, detail="Variable not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(variable, key, value)
    db.commit()
    db.refresh(variable)
    return _serialize_variable(variable)


@variable_router.delete("/{variable_id}")
def delete_variable(
    variable_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    variable = db.query(SemesterVariable).filter(
        SemesterVariable.id == variable_id, SemesterVariable.user_id == current_user.id
    ).first()
    if not variable:
        raise HTTPException(status_code=404, detail="Variable not found")
    db.delete(variable)
    db.commit()
    return {"message": "Variable deleted"}


# ─────────────────────────────────────────────────────────────────────────────
# GPA COMPUTATION
# ─────────────────────────────────────────────────────────────────────────────

@router.get("/{semester_id}/grade")
def compute_semester_grade(
    semester_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Compute weighted average for a semester. Returns NULL if any variable is incomplete."""
    semester = db.query(Semester).filter(
        Semester.id == semester_id, Semester.user_id == current_user.id
    ).first()
    if not semester:
        raise HTTPException(status_code=404, detail="Semester not found")
    
    variables = db.query(SemesterVariable).filter(SemesterVariable.semester_id == semester_id).all()
    if not variables:
        return {"semester_id": semester_id, "grade": None, "reason": "No variables"}
    
    total_weight = sum(v.weight or 0 for v in variables)
    if abs(total_weight - 100.0) > 0.01:
        return {"semester_id": semester_id, "grade": None, "reason": f"Weights must sum to 100% (current: {total_weight}%)"}
    
    weighted_sum = 0.0
    for v in variables:
        if v.score is None or v.total_score is None or v.weight is None:
            return {"semester_id": semester_id, "grade": None, "reason": f"Variable '{v.name}' has NULL values"}
        if v.total_score == 0:
            return {"semester_id": semester_id, "grade": None, "reason": f"Variable '{v.name}' has zero total_score"}
        percentage = (v.score / v.total_score) * 100
        weighted_sum += percentage * (v.weight / 100.0)
    
    return {"semester_id": semester_id, "grade": round(weighted_sum, 2)}


@router.get("/student/{student_id}/gpa")
def compute_student_gpa(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Compute final GPA = Prelim(25%) + Midterm(45%) + Finals(40%)
    Returns NULL if any semester grade is NULL.
    """
    semesters = db.query(Semester).filter(
        Semester.student_id == student_id, Semester.user_id == current_user.id
    ).all()
    
    grades = {}
    for sem in semesters:
        result = compute_semester_grade(str(sem.id), db, current_user)
        if result["grade"] is None:
            grades[sem.term] = None
        else:
            grades[sem.term] = result["grade"]
    
    prelim = grades.get("prelim")
    midterm = grades.get("midterm")
    finals = grades.get("finals")
    
    if prelim is None or midterm is None or finals is None:
        return {
            "student_id": student_id,
            "gpa": None,
            "prelim": prelim,
            "midterm": midterm,
            "finals": finals,
            "reason": "One or more semester grades are incomplete"
        }
    
    gpa = (prelim * 0.25) + (midterm * 0.45) + (finals * 0.40)
    return {
        "student_id": student_id,
        "gpa": round(gpa, 2),
        "prelim": prelim,
        "midterm": midterm,
        "finals": finals,
    }
