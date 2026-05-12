"""
EduScan — Neon PostgreSQL Database Configuration
Uses SQLAlchemy ORM with asyncpg (async) or psycopg2 (sync) driver.
This module uses sync SQLAlchemy for simplicity with FastAPI endpoints.
"""
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set in .env")

# Neon requires SSL
engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_size=5, max_overflow=10)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    """Shared declarative base for all ORM models."""
    pass


def get_db():
    """FastAPI dependency: yields a DB session and closes it after use."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()