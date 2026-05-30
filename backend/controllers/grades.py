"""
Grades / GPA controller — computes GPA using MSU-TCTO formula.
Hierarchical grade viewing: Student → Subject → Exam Results
MSU-TCTO Grading Scale: 1.0 (Excellent) to 5.0 (Failed)
"""
from fastapi import APIRouter, Query, Depends, HTTPException
from typing import Optional, Dict, List
from sqlalchemy.orm import Session, joinedload

from database import get_db
from controllers.auth import get_current_user
from models.exam_result import ExamResult
from models.exam import Exam
from models.subject import Subject
from models.student import Student
from models.user import User

router = APIRouter(prefix="/grades", tags=["Grades"])


# MSU-TCTO Grading Scale
MSU_TCTO_SCALE = {
    (96, 100): {"grade": "1.0", "point": 1.0, "description": "Excellent"},
    (92, 95): {"grade": "1.25", "point": 1.25, "description": "Very Good"},
    (88, 91): {"grade": "1.5", "point": 1.5, "description": "Good"},
    (84, 87): {"grade": "1.75", "point": 1.75, "description": "Good"},
    (80, 83): {"grade": "2.0", "point": 2.0, "description": "Satisfactory"},
    (76, 79): {"grade": "2.25", "point": 2.25, "description": "Satisfactory"},
    (72, 75): {"grade": "2.5", "point": 2.5, "description": "Satisfactory"},
    (68, 71): {"grade": "2.75", "point": 2.75, "description": "Passing"},
    (60, 67): {"grade": "3.0", "point": 3.0, "description": "Passing"},
    (0, 59): {"grade": "5.0", "point": 5.0, "description": "Failed"},
}


def _get_msu_tcto_grade(percentage: float) -> Dict:
    """Get MSU-TCTO grade based on percentage."""
    for (min_pct, max_pct), grade_info in MSU_TCTO_SCALE.items():
        if min_pct <= percentage <= max_pct:
            return grade_info
    return {"grade": "5.0", "point": 5.0, "description": "Failed"}


def _interpret_gpa(gpa: float) -> str:
    """Interpret GPA value."""
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


@router.get("/student/{student_id}")
def get_student_grades(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get all grades for a student grouped by subject.
    Hierarchy: Student → Subject → Exam Results
    """
    student = db.query(Student).filter(
        Student.id == student_id,
        Student.user_id == current_user.id
    ).first()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    results = db.query(ExamResult).options(
        joinedload(ExamResult.exam).joinedload(Exam.subject)
    ).filter(
        ExamResult.student_id == student_id,
        ExamResult.user_id == current_user.id
    ).order_by(ExamResult.created_at.desc()).all()
    
    # Group by subject
    subjects_dict: Dict[str, Dict] = {}
    
    for result in results:
        if not result.exam or not result.exam.subject:
            continue
        
        subject = result.exam.subject
        subject_id = str(subject.id)
        
        if subject_id not in subjects_dict:
            subjects_dict[subject_id] = {
                "subject_id": subject_id,
                "subject_code": subject.code,
                "subject_name": subject.name,
                "units": subject.units,
                "exams": [],
            }
        
        subjects_dict[subject_id]["exams"].append({
            "exam_id": str(result.exam.id),
            "exam_name": result.exam.name,
            "exam_type": result.exam.exam_type,
            "percentage": result.percentage,
            "grade": result.grade,
            "grade_point": result.grade_point,
            "remarks": result.remarks,
            "created_at": result.created_at.isoformat() if result.created_at else None,
        })
    
    # Calculate subject averages
    for subject_id, subject_data in subjects_dict.items():
        if subject_data["exams"]:
            avg_percentage = sum(e["percentage"] or 0 for e in subject_data["exams"]) / len(subject_data["exams"])
            avg_grade_point = sum(e["grade_point"] or 0 for e in subject_data["exams"]) / len(subject_data["exams"])
            subject_data["average_percentage"] = round(avg_percentage, 2)
            subject_data["average_grade_point"] = round(avg_grade_point, 2)
            subject_data["average_grade"] = _get_msu_tcto_grade(avg_percentage)["grade"]
    
    return {
        "student_id": student_id,
        "student_name": f"{student.first_name} {student.last_name}",
        "student_id_number": student.student_id,
        "course": student.course,
        "year_level": student.year_level,
        "subjects": list(subjects_dict.values()),
        "total_subjects": len(subjects_dict),
    }


@router.get("/student/{student_id}/subject/{subject_id}")
def get_student_subject_grades(
    student_id: str,
    subject_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get detailed grades for a student in a specific subject.
    """
    student = db.query(Student).filter(
        Student.id == student_id,
        Student.user_id == current_user.id
    ).first()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    subject = db.query(Subject).filter(
        Subject.id == subject_id,
        Subject.user_id == current_user.id
    ).first()
    
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")
    
    results = db.query(ExamResult).options(
        joinedload(ExamResult.exam)
    ).filter(
        ExamResult.student_id == student_id,
        ExamResult.user_id == current_user.id,
        ExamResult.exam.has(Exam.subject_id == subject_id)
    ).order_by(ExamResult.created_at.desc()).all()
    
    exams = []
    for result in results:
        exams.append({
            "exam_id": str(result.exam.id),
            "exam_name": result.exam.name,
            "exam_type": result.exam.exam_type,
            "total_items": result.exam.total_items,
            "points_per_item": result.exam.points_per_item,
            "correct_answers": result.correct_answers,
            "total_score": result.total_score,
            "percentage": result.percentage,
            "grade": result.grade,
            "grade_point": result.grade_point,
            "remarks": result.remarks,
            "created_at": result.created_at.isoformat() if result.created_at else None,
        })
    
    # Calculate subject average
    if exams:
        avg_percentage = sum(e["percentage"] or 0 for e in exams) / len(exams)
        avg_grade_point = sum(e["grade_point"] or 0 for e in exams) / len(exams)
        final_grade_info = _get_msu_tcto_grade(avg_percentage)
    else:
        avg_percentage = 0
        avg_grade_point = 0
        final_grade_info = {"grade": "N/A", "point": 0, "description": "No grades"}
    
    return {
        "student_id": student_id,
        "student_name": f"{student.first_name} {student.last_name}",
        "subject_id": subject_id,
        "subject_code": subject.code,
        "subject_name": subject.name,
        "units": subject.units,
        "exams": exams,
        "subject_average": {
            "percentage": round(avg_percentage, 2),
            "grade_point": round(avg_grade_point, 2),
            "grade": final_grade_info["grade"],
            "description": final_grade_info["description"],
        },
    }


@router.get("/student/{student_id}/gpa")
def get_student_gpa(
    student_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Calculate GPA for a student using MSU-TCTO formula.
    GPA = Σ(grade_point × units) / Σ(units)
    """
    student = db.query(Student).filter(
        Student.id == student_id,
        Student.user_id == current_user.id
    ).first()
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    results = db.query(ExamResult).options(
        joinedload(ExamResult.exam).joinedload(Exam.subject)
    ).filter(
        ExamResult.student_id == student_id,
        ExamResult.user_id == current_user.id
    ).all()
    
    if not results:
        return {
            "student_id": student_id,
            "student_name": f"{student.first_name} {student.last_name}",
            "gpa": None,
            "total_units": 0,
            "subjects_counted": 0,
            "message": "No grades recorded yet"
        }
    
    # Group by subject and calculate average
    subject_grades: Dict[str, Dict] = {}
    
    for result in results:
        if not result.exam or not result.exam.subject or result.grade_point is None:
            continue
        
        subject = result.exam.subject
        subject_id = str(subject.id)
        
        if subject_id not in subject_grades:
            subject_grades[subject_id] = {
                "subject_code": subject.code,
                "subject_name": subject.name,
                "units": subject.units,
                "grade_points": [],
            }
        
        subject_grades[subject_id]["grade_points"].append(result.grade_point)
    
    # Calculate GPA
    weighted_sum = 0.0
    total_units = 0
    subject_list = []
    
    for subject_id, subject_data in subject_grades.items():
        avg_grade_point = sum(subject_data["grade_points"]) / len(subject_data["grade_points"])
        units = subject_data["units"]
        
        weighted_sum += avg_grade_point * units
        total_units += units
        
        subject_list.append({
            "subject_code": subject_data["subject_code"],
            "subject_name": subject_data["subject_name"],
            "units": units,
            "average_grade_point": round(avg_grade_point, 2),
        })
    
    gpa = round(weighted_sum / total_units, 4) if total_units > 0 else None
    
    return {
        "student_id": student_id,
        "student_name": f"{student.first_name} {student.last_name}",
        "gpa": gpa,
        "gpa_interpretation": _interpret_gpa(gpa) if gpa else "N/A",
        "total_units": total_units,
        "subjects_counted": len(subject_grades),
        "subjects": subject_list,
        "grading_system": "MSU-TCTO",
    }