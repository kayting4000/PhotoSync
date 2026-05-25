"""
Student-Subject model — represents the 'student_subjects' table in Neon PostgreSQL.
Links students to subjects and their specific sections.
"""
import uuid
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "student_subjects"


class StudentSubject(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    student_id = Column(UUID(as_uuid=True), ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    subject_id = Column(UUID(as_uuid=True), ForeignKey("subjects.id", ondelete="CASCADE"), nullable=False)
    section_id = Column(UUID(as_uuid=True), ForeignKey("sections.id", ondelete="SET NULL"), nullable=True)
    semester = Column(String, nullable=False)
    academic_year = Column(String, nullable=False)
    final_grade = Column(Float, nullable=True)
    grade_equivalent = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="student_subjects")
    student = relationship("Student", backref="student_subjects")
    subject = relationship("Subject", backref="student_subjects")
    section = relationship("Section", back_populates="student_subjects")