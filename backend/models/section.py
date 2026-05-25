"""
Section model — represents the 'sections' table in Neon PostgreSQL.
A section is a subsection of a subject (A, B, C, D, E).
Each section has a specific room and student list.
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "sections"


class Section(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    subject_id = Column(UUID(as_uuid=True), ForeignKey("subjects.id", ondelete="CASCADE"), nullable=False, index=True)
    section_label = Column(String, nullable=False)  # A, B, C, D, E
    room_number = Column(String, nullable=False)  # e.g., "Room 101", "Lab A"
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="sections")
    subject = relationship("Subject", backref="sections")
    student_subjects = relationship("StudentSubject", back_populates="section", cascade="all, delete-orphan")