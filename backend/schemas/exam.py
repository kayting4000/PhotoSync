from pydantic import BaseModel
from typing import Optional


class ExamCreate(BaseModel):
    subject_id: str
    name: str
    component_type: str  # "exam", "quiz", "assignment", "oral"
    total_items: int
    points_per_item: float = 1.0
    passing_score: Optional[float] = None
    term_id: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "subject_id": "uuid-of-subject",
                    "name": "Midterm Exam",
                    "component_type": "exam",
                    "total_items": 50,
                    "points_per_item": 2.0,
                    "passing_score": 60.0,
                    "term_id": "uuid-of-term"
                }
            ]
        }
    }


class ExamUpdate(BaseModel):
    subject_id: Optional[str] = None
    name: Optional[str] = None
    component_type: Optional[str] = None  # "exam", "quiz", "assignment", "oral"
    total_items: Optional[int] = None
    points_per_item: Optional[float] = None
    passing_score: Optional[float] = None
    term_id: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "name": "Final Exam",
                    "component_type": "exam",
                    "total_items": 60,
                    "points_per_item": 2.0,
                    "passing_score": 70.0
                }
            ]
        }
    }
