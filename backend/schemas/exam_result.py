from pydantic import BaseModel
from typing import Optional


class ExamResultCreate(BaseModel):
    student_id: str
    exam_id: str
    correct_answers: int
    total_score: float
    percentage: Optional[float] = None
    grade: Optional[str] = None        # MSU scale: 1.0, 1.25 ... 3.0, 5.0
    grade_point: Optional[float] = None
    remarks: Optional[str] = None
    scanned_image_url: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "student_id": "uuid-of-student",
                    "exam_id": "uuid-of-exam",
                    "correct_answers": 45,
                    "total_score": 90.0,
                    "percentage": 90.0,
                    "grade": "1.25",
                    "grade_point": 1.25,
                    "remarks": "Passed",
                    "scanned_image_url": None
                }
            ]
        }
    }


class ExamResultUpdate(BaseModel):
    correct_answers: Optional[int] = None
    total_score: Optional[float] = None
    percentage: Optional[float] = None
    grade: Optional[str] = None
    grade_point: Optional[float] = None
    remarks: Optional[str] = None
    scanned_image_url: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "correct_answers": 48,
                    "total_score": 96.0,
                    "percentage": 96.0,
                    "grade": "1.0",
                    "grade_point": 1.0,
                    "remarks": "Passed"
                }
            ]
        }
    }
