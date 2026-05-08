from pydantic import BaseModel
from typing import Optional


class SubjectCreate(BaseModel):
    code: str
    name: str
    units: int = 3


class SubjectUpdate(BaseModel):
    code: Optional[str] = None
    name: Optional[str] = None
    units: Optional[int] = None
