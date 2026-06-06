"""
SemesterVariable model — manual grade components (Exams, Quizzes, etc.)
All values start as NULL until user inputs them.
"""
import uuid
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


class SemesterVariable(Base):
    __tablename__ = "semester_variables"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    semester_id = Column(UUID(as_uuid=True), ForeignKey("semesters.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String, nullable=False)           # e.g. "Exams", "Quizzes"
    score = Column(Float, nullable=True)            # NULL until user inputs
    total_score = Column(Float, nullable=True)      # NULL until user inputs
    weight = Column(Float, nullable=True)           # NULL until user inputs (0-100)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    semester = relationship("Semester", back_populates="variables")
