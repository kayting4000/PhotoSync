from pydantic import BaseModel, EmailStr
from typing import Optional


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
