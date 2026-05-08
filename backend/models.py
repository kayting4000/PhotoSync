from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class StudentCreate(BaseModel):
    student_id: str
    first_name: str
    last_name: str
    email: Optional[str] = None
    course: str
    year_level: int = 1


class StudentUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    course: Optional[str] = None
    year_level: Optional[int] = None


class SubjectCreate(BaseModel):
    code: str
    name: str
    units: int = 3


class SubjectUpdate(BaseModel):
    code: Optional[str] = None
    name: Optional[str] = None
    units: Optional[int] = None


class ExamCreate(BaseModel):
    subject_id: str
    name: str
    exam_type: str
    total_items: int
    points_per_item: float = 1.0
    passing_score: Optional[float] = None


class ExamResultCreate(BaseModel):
    student_id: str
    exam_id: str
    correct_answers: int
    total_score: float
    percentage: Optional[float] = None
    grade: Optional[str] = None
    remarks: Optional[str] = None
    scanned_image_url: Optional[str] = None


class EmailRequest(BaseModel):
    subject_id: str
    message: Optional[str] = ""


class AuthLogin(BaseModel):
    email: EmailStr
    password: str


class AuthSignup(BaseModel):
    email: EmailStr
    password: str
