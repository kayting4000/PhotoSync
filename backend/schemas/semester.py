from pydantic import BaseModel
from typing import Optional, Literal


class SemesterCreate(BaseModel):
    student_id: str
    term: Literal["prelim", "midterm", "finals"]


class SemesterUpdate(BaseModel):
    term: Optional[Literal["prelim", "midterm", "finals"]] = None


class SemesterVariableCreate(BaseModel):
    semester_id: str
    name: str
    score: Optional[float] = None        # NULL by default
    total_score: Optional[float] = None  # NULL by default
    weight: Optional[float] = None       # NULL by default


class SemesterVariableUpdate(BaseModel):
    name: Optional[str] = None
    score: Optional[float] = None
    total_score: Optional[float] = None
    weight: Optional[float] = None
