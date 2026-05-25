"""
Academic Term model — represents the 'academic_terms' table in Neon PostgreSQL.
"""
import uuid
from sqlalchemy import Column, String, Date, Boolean, DateTime, ForeignKey, text, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from database import Base


TABLE = "academic_terms"


class AcademicTerm(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    term_type = Column(String, nullable=False)  # "preliminary", "mid-semester", "final"
    percentage_weight = Column(Integer, nullable=False, default=33)  # 10-90% contribution to final grade
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    is_current = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))

    # Relationships
    user = relationship("User", backref="academic_terms")