from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import relationship
from database import Base
import uuid
from datetime import datetime

class Section(Base):
    __tablename__ = "sections"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, nullable=False)

    subject_id = Column(String, nullable=False)

    section_label = Column(String, nullable=False)
    room_number = Column(String, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    # 🔥 IMPORTANT RELATION
    students = relationship(
        "Student",
        back_populates="section",
        cascade="all, delete"
    )