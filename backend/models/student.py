"""
Student model — represents the 'students' table in Supabase (PostgreSQL).
"""

from sqlalchemy import Column, String, Integer, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


TABLE = "students"


class Student(Base):
    __tablename__ = TABLE

    id         = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    student_id = Column(String, unique=True, nullable=False)
    first_name = Column(String, nullable=False)
    last_name  = Column(String, nullable=False)
    email      = Column(String, nullable=True)
    course     = Column(String, nullable=False)
    year_level = Column(Integer, nullable=False, default=1)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))
