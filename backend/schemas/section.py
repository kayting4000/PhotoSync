from pydantic import BaseModel
from typing import Optional


class SectionCreate(BaseModel):
    subject_id: str
    section_label: str  # A, B, C, D, E
    room_number: str  # e.g., "Room 101", "Lab A"

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "subject_id": "uuid-of-physics-subject",
                    "section_label": "A",
                    "room_number": "Room 101"
                },
                {
                    "subject_id": "uuid-of-chemistry-subject",
                    "section_label": "B",
                    "room_number": "Lab 202"
                }
            ]
        }
    }


class SectionUpdate(BaseModel):
    section_label: Optional[str] = None  # A, B, C, D, E
    room_number: Optional[str] = None  # Room number

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "section_label": "A",
                    "room_number": "Room 102"
                }
            ]
        }
    }