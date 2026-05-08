from pydantic import BaseModel
from typing import Optional


class ExamCreate(BaseModel):
    subject_id: str
    name: str
    exam_type: str
    total_items: int
    points_per_item: float = 1.0
    passing_score: Optional[float] = None
