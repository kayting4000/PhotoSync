from pydantic import BaseModel
from typing import Optional


class ExamResultCreate(BaseModel):
    student_id: str
    exam_id: str
    correct_answers: int
    total_score: float
    percentage: Optional[float] = None
    grade: Optional[str] = None
    remarks: Optional[str] = None
    scanned_image_url: Optional[str] = None
