"""
Subject model — represents the 'subjects' table in Neon PostgreSQL.
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "subjects"


class Subject(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    code = Column(String, nullable=False)
    name = Column(String, nullable=False)
    units = Column(Integer, nullable=False, default=3)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="subjects")
    exams = relationship("Exam", back_populates="subject", cascade="all, delete-orphan")