"""
Semester model — Prelim / Midterm / Finals per student.
"""
import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


class Semester(Base):
    __tablename__ = "semesters"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    student_id = Column(UUID(as_uuid=True), ForeignKey("students.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    # 'prelim' | 'midterm' | 'finals'
    term = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    student = relationship("Student", backref="semesters")
    variables = relationship("SemesterVariable", back_populates="semester", cascade="all, delete-orphan")
