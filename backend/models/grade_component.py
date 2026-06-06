from sqlalchemy import Column, String, Float, ForeignKey, DateTime
from database import Base
from datetime import datetime
import uuid


class GradeComponent(Base):
    __tablename__ = "grade_components"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    student_id = Column(String, ForeignKey("students.id"))
    section_id = Column(String, ForeignKey("sections.id"))

    name = Column(String)  # exam, quiz, lab, etc.
    term = Column(String)  # prelim, midterm, finals

    score = Column(Float, default=0)
    weight = Column(Float, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)