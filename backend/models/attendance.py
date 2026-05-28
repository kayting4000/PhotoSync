"""
Attendance model — monthly attendance records per student.
"""
import uuid
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


class Attendance(Base):
    __tablename__ = "attendance"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    student_id = Column(UUID(as_uuid=True), ForeignKey("students.id", ondelete="CASCADE"), nullable=False, index=True)
    subject_id = Column(UUID(as_uuid=True), ForeignKey("subjects.id", ondelete="CASCADE"), nullable=False, index=True)
    year = Column(Integer, nullable=False)
    month = Column(Integer, nullable=False)  # 1-12
    day = Column(Integer, nullable=False)    # 1-31
    status = Column(String, nullable=False)  # "present", "late", "absent"
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    user = relationship("User", backref="attendance")
    student = relationship("Student", backref="attendance")
    subject = relationship("Subject", backref="attendance")
