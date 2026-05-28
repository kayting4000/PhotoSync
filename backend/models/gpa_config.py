"""
GPA Config model — per-user customizable term percentage weights.
"""
import uuid
from sqlalchemy import Column, Integer, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


class GpaConfig(Base):
    __tablename__ = "gpa_config"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    prelim_pct = Column(Integer, nullable=False, default=33)    # e.g. 10
    midterm_pct = Column(Integer, nullable=False, default=33)   # e.g. 30
    finals_pct = Column(Integer, nullable=False, default=34)    # e.g. 60
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))
    updated_at = Column(DateTime(timezone=True), server_default=text("now()"), onupdate=text("now()"))

    user = relationship("User", backref="gpa_config")
