"""
User model — represents the 'users' table in Neon PostgreSQL.
Replaces Supabase Auth with a local users table.
"""
from sqlalchemy import Column, String, DateTime, Boolean, text
from sqlalchemy.dialects.postgresql import UUID
from database import Base


TABLE = "users"


class User(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))