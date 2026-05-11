from pydantic import BaseModel
from typing import Optional


class SubjectCreate(BaseModel):
    code: str
    name: str
    units: int = 3

    model_config = {
        "json_schema_extra": {
            "examples": [
                {"code": "CS101", "name": "Introduction to Computing", "units": 3}
            ]
        }
    }


class SubjectUpdate(BaseModel):
    code: Optional[str] = None
    name: Optional[str] = None
    units: Optional[int] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {"code": "CS101", "name": "Introduction to Computing", "units": 3}
            ]
        }
    }
