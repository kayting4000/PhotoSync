"""
User model — represents the 'users' table in Neon PostgreSQL.
Replaces Supabase Auth with a local users table.
Now includes role-based access control (RBAC) with roles:
  - admin   : full access
  - teacher : manage students, subjects, exams, grades
  - student : read-only access to own data
"""
import uuid
from sqlalchemy import Column, String, DateTime, Boolean, text
from sqlalchemy.dialects.postgresql import UUID
from database import Base


TABLE = "users"


class User(Base):
    __tablename__ = TABLE

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    role = Column(String, nullable=False, default='admin')  # 'admin', 'teacher', 'student'
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), server_default=text("now()"))