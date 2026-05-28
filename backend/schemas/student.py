from pydantic import BaseModel
from typing import Optional


class StudentCreate(BaseModel):
    student_id: str
    first_name: str
    middle_initial: Optional[str] = None
    last_name: str
    email: Optional[str] = None
    parent_guardian_email: Optional[str] = None
    course: str
    year_level: int = 1
    section_id: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "student_id": "2021-00123",
                    "first_name": "Juan",
                    "middle_initial": "M",
                    "last_name": "Dela Cruz",
                    "email": "juan.delacruz@example.com",
                    "parent_guardian_email": "parent.delacruz@example.com",
                    "course": "BSCS",
                    "year_level": 2
                }
            ]
        }
    }


class StudentUpdate(BaseModel):
    first_name: Optional[str] = None
    middle_initial: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    parent_guardian_email: Optional[str] = None
    course: Optional[str] = None
    year_level: Optional[int] = None
    section_id: Optional[str] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "first_name": "Juan",
                    "middle_initial": "M",
                    "last_name": "Dela Cruz",
                    "email": "juan.delacruz@example.com",
                    "parent_guardian_email": "parent.delacruz@example.com",
                    "course": "BSIT",
                    "year_level": 3
                }
            ]
        }
    }
