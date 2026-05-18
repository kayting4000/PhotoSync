"""
Scoring Rule model — represents the 'scoring_rules' table in Neon PostgreSQL.
"""
import uuid
from sqlalchemy import Column, String, Float, Integer, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "scoring_rules"


class ScoringRule(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    exam_id = Column(UUID(as_uuid=True), ForeignKey("exams.id", ondelete="CASCADE"), nullable=False)
    section_name = Column(String, nullable=True)
    item_start = Column(Integer, nullable=False, default=1)
    item_end = Column(Integer, nullable=False)
    points_per_item = Column(Float, nullable=False, default=1.0)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="scoring_rules")
    exam = relationship("Exam", backref="scoring_rules")