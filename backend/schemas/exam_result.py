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
