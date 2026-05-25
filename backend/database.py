"""
PhotoSync — Neon PostgreSQL Database Configuration
Uses SQLAlchemy ORM with psycopg2 driver.
"""
import os
import re
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# Load .env from the backend/ directory explicitly
dotenv_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set in .env")

# Strip unsupported URL parameters that psycopg2 can't parse
DATABASE_URL = re.sub(r'[?&]channel_binding=\w+', '', DATABASE_URL)

# Optimized connection pooling for Neon PostgreSQL
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,   # Verify connections before use
    pool_size=10,          # Keep up to 10 persistent connections
    max_overflow=20,       # Allow up to 20 additional overflow connections
    pool_recycle=3600,     # Recycle connections after 1 hour
)
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