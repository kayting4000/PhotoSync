from pydantic import BaseModel
from typing import Optional


class AttendanceCreate(BaseModel):
    student_id: str
    subject_id: str
    year: int
    month: int
    day: int
    status: str  # "present", "late", "absent"


class AttendanceUpdate(BaseModel):
    status: str


class AttendanceSummary(BaseModel):
    student_id: str
    subject_id: str
    year: int
    month: Optional[int] = None
    present: int
    late: int
    absent: int
