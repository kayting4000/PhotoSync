"""
Portal schemas — response models for the Student Mobile Portal (read-only).
"""
from pydantic import BaseModel
from typing import Optional


class PortalStudentInfo(BaseModel):
    id: str
    student_id: str
    first_name: str
    last_name: str
    email: Optional[str] = None
    course: str
    year_level: int
    section_label: Optional[str] = None


class PortalGrade(BaseModel):
    exam_name: str
    subject_code: str
    subject_name: str
    percentage: float
    grade: str
    grade_point: float
    remarks: str


class PortalAttendance(BaseModel):
    subject_name: str
    subject_code: str
    year: int
    month: int
    day: int
    status: str  # "present", "late", "absent"


class PortalExam(BaseModel):
    id: str
    name: str
    subject_code: str
    subject_name: str
    total_items: int
    component_type: str


class PortalGradeSummary(BaseModel):
    subject_code: str
    subject_name: str
    units: int
    grade: str
    grade_point: float
    remarks: str


class PortalDashboard(BaseModel):
    total_subjects: int
    total_exams: int
    attendance_rate: float  # percentage
    current_gpa: float