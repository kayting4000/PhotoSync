from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models.section import Section

router = APIRouter()

# 🔥 GET ALL SECTIONS WITH STUDENT COUNT
@router.get("/")
def get_sections(db: Session = Depends(get_db)):
    sections = db.query(Section).all()

    result = []
    for section in sections:
        result.append({
            "id": section.id,
            "section_label": section.section_label,
            "room_number": section.room_number,

            # 🔥 REAL COUNT (FIXES YOUR "0 students" BUG)
            "student_count": len(section.students),

            # 🔥 THIS MAKES IT ACT LIKE A FOLDER
            "students": [
                {
                    "id": s.id,
                    "student_id": s.student_id,
                    "first_name": s.first_name,
                    "last_name": s.last_name
                }
                for s in section.students
            ]
        })

    return result


# 🔥 GET SINGLE SECTION (FOLDER VIEW)
@router.get("/{section_id}")
def get_section(section_id: str, db: Session = Depends(get_db)):
    section = db.query(Section).filter(Section.id == section_id).first()

    if not section:
        return {"error": "Section not found"}

    return {
        "id": section.id,
        "section_label": section.section_label,
        "room_number": section.room_number,
        "student_count": len(section.students),
        "students": section.students
    }