from pydantic import BaseModel
from typing import Optional


class GradeCreate(BaseModel):
    student_id: str
    section_id: str
    name: str
    term: str
    score: float
    weight: float


class GradeUpdate(BaseModel):
    score: Optional[float] = None
    weight: Optional[float] = None