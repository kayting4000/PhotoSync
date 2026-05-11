"""
ExamResult model — represents the 'exam_results' table in Supabase (PostgreSQL).

Columns:
  id                uuid   PRIMARY KEY DEFAULT gen_random_uuid()
  student_id        uuid   REFERENCES students(id)
  exam_id           uuid   REFERENCES exams(id)
  correct_answers   int    NOT NULL
  total_score       float  NOT NULL
  percentage        float
  grade             text
  grade_point       float
  remarks           text
  scanned_image_url text
  created_at        timestamptz DEFAULT now()
"""

from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


TABLE = "exam_results"


class ExamResult(Base):
    __tablename__ = TABLE

    id                = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    student_id        = Column(UUID(as_uuid=True), ForeignKey("students.id"), nullable=False)
    exam_id           = Column(UUID(as_uuid=True), ForeignKey("exams.id"), nullable=False)
    correct_answers   = Column(Integer, nullable=False)
    total_score       = Column(Float, nullable=False)
    percentage        = Column(Float, nullable=True)
    grade             = Column(String, nullable=True)
    grade_point       = Column(Float, nullable=True)
    remarks           = Column(String, nullable=True)
    scanned_image_url = Column(String, nullable=True)
    created_at        = Column(DateTime(timezone=True), server_default=text("now()"))