"""
Exam model — represents the 'exams' table in Supabase (PostgreSQL).

Columns:
  id               uuid   PRIMARY KEY DEFAULT gen_random_uuid()
  subject_id       uuid   REFERENCES subjects(id)
  name             text   NOT NULL
  exam_type        text   NOT NULL
  total_items      int    NOT NULL
  points_per_item  float  NOT NULL DEFAULT 1.0
  passing_score    float
  created_at       timestamptz DEFAULT now()
"""

from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


TABLE = "exams"


class Exam(Base):
    __tablename__ = TABLE

    id              = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    subject_id      = Column(UUID(as_uuid=True), ForeignKey("subjects.id"), nullable=False)
    name            = Column(String, nullable=False)
    exam_type       = Column(String, nullable=False)
    total_items     = Column(Integer, nullable=False)
    points_per_item = Column(Float, nullable=False, default=1.0)
    passing_score   = Column(Float, nullable=True)
    created_at      = Column(DateTime(timezone=True), server_default=text("now()"))