"""
Exam model — represents the 'exams' table in Neon PostgreSQL.
"""
import uuid
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "exams"


class Exam(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    subject_id = Column(UUID(as_uuid=True), ForeignKey("subjects.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    exam_type = Column(String, nullable=False)
    total_items = Column(Integer, nullable=False)
    points_per_item = Column(Float, nullable=False, default=1.0)
    passing_score = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="exams")
    subject = relationship("Subject", back_populates="exams")
    exam_results = relationship("ExamResult", back_populates="exam", cascade="all, delete-orphan")