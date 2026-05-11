"""
Subject model — represents the 'subjects' table in Supabase (PostgreSQL).
"""

from sqlalchemy import Column, String, Integer, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


TABLE = "subjects"


class Subject(Base):
    __tablename__ = TABLE

    id         = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    code       = Column(String, unique=True, nullable=False)
    name       = Column(String, nullable=False)
    units      = Column(Integer, nullable=False, default=3)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))
