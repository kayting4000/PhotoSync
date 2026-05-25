from pydantic import BaseModel, field_validator
from typing import Optional
from datetime import date


class AcademicTermCreate(BaseModel):
    name: str
    term_type: str  # "preliminary", "mid-semester", "final"
    percentage_weight: int = 33  # 10-90% contribution to final grade
    start_date: date
    end_date: date
    is_current: bool = False

    @field_validator('percentage_weight')
    @classmethod
    def validate_percentage(cls, v):
        if not (10 <= v <= 90):
            raise ValueError('percentage_weight must be between 10 and 90')
        return v

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "name": "Preliminary Term",
                    "term_type": "preliminary",
                    "percentage_weight": 30,
                    "start_date": "2026-01-10",
                    "end_date": "2026-02-28",
                    "is_current": True
                }
            ]
        }
    }


class AcademicTermUpdate(BaseModel):
    name: Optional[str] = None
    term_type: Optional[str] = None
    percentage_weight: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    is_current: Optional[bool] = None

    @field_validator('percentage_weight')
    @classmethod
    def validate_percentage(cls, v):
        if v is not None and not (10 <= v <= 90):
            raise ValueError('percentage_weight must be between 10 and 90')
        return v

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "name": "Mid-Semester Term",
                    "term_type": "mid-semester",
                    "percentage_weight": 35,
                    "start_date": "2026-03-01",
                    "end_date": "2026-04-15",
                    "is_current": True
                }
            ]
        }
    }