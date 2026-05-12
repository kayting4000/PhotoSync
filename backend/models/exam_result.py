"""
ExamResult model — represents the 'exam_results' table in Neon PostgreSQL.
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "exam_results"


class ExamResult(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    student_id = Column(UUID(as_uuid=True), ForeignKey("students.id", ondelete="CASCADE"), nullable=False)
    exam_id = Column(UUID(as_uuid=True), ForeignKey("exams.id", ondelete="CASCADE"), nullable=False)
    correct_answers = Column(Integer, nullable=False, default=0)
    total_score = Column(Float, nullable=False, default=0.0)
    percentage = Column(Float, nullable=True)
    grade = Column(String, nullable=True)
    grade_point = Column(Float, nullable=True)
    remarks = Column(String, nullable=True)
    scanned_image_url = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="exam_results")
    student = relationship("Student", back_populates="exam_results")
    exam = relationship("Exam", back_populates="exam_results")