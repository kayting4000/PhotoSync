from pydantic import BaseModel
from typing import Optional


class ScoringRuleCreate(BaseModel):
    exam_id: str
    section_name: Optional[str] = None
    item_start: int = 1
    item_end: int
    points_per_item: float = 1.0

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "exam_id": "uuid-of-exam",
                    "section_name": "Multiple Choice",
                    "item_start": 1,
                    "item_end": 25,
                    "points_per_item": 2.0,
                }
            ]
        }
    }


class ScoringRuleUpdate(BaseModel):
    section_name: Optional[str] = None
    item_start: Optional[int] = None
    item_end: Optional[int] = None
    points_per_item: Optional[float] = None

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "points_per_item": 2.0,
                }
            ]
        }
    }