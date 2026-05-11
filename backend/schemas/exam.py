from pydantic import BaseModel
from typing import Optional


class ExamCreate(BaseModel):
    subject_id: str
    name: str
    exam_type: str
    total_items: int
    points_per_item: float = 1.0
    passing_score: Optional[float] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "subject_id": "uuid-of-subject",
                    "name": "Midterm Exam",
                    "exam_type": "midterm",
                    "total_items": 50,
                    "points_per_item": 2.0,
                    "passing_score": 60.0
                }
            ]
        }
    }


class ExamUpdate(BaseModel):
    subject_id: Optional[str] = None
    name: Optional[str] = None
    exam_type: Optional[str] = None
    total_items: Optional[int] = None
    points_per_item: Optional[float] = None
    passing_score: Optional[float] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "name": "Final Exam",
                    "exam_type": "final",
                    "total_items": 60,
                    "points_per_item": 2.0,
                    "passing_score": 70.0
                }
            ]
        }
    }
