from pydantic import BaseModel
from typing import Optional


class StudentSubjectCreate(BaseModel):
    student_id: str
    subject_id: str
    semester: str
    academic_year: str
    final_grade: Optional[float] = None
    grade_equivalent: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "student_id": "uuid-of-student",
                    "subject_id": "uuid-of-subject",
                    "semester": "1st",
                    "academic_year": "2025-2026",
                    "final_grade": 1.5,
                    "grade_equivalent": "1.5",
                }
            ]
        }
    }


class StudentSubjectUpdate(BaseModel):
    semester: Optional[str] = None
    academic_year: Optional[str] = None
    final_grade: Optional[float] = None
    grade_equivalent: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "final_grade": 1.0,
                    "grade_equivalent": "1.0",
                }
            ]
        }
    }