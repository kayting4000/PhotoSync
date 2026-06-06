"""
PhotoSync — Neon PostgreSQL Database Configuration
Uses SQLAlchemy ORM with psycopg2 driver.
"""
from pathlib import Path
import os
import re
from dotenv import load_dotenv
from datetime import datetime

from sqlalchemy import create_engine, event
from sqlalchemy.orm import declarative_base, sessionmaker

# Load backend/.env explicitly
dotenv_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL") or "sqlite:///./photosync.db"

# Remove unsupported URL params (safe guard)
DATABASE_URL = re.sub(r'[?&]channel_binding=\w+', '', DATABASE_URL)

# Engine selection
if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        future=True,
        echo=False,
        pool_pre_ping=True,
        implicit_returning=False,  # avoid RETURNING for SQLite
    )

    # Provide a now() SQL function so server-default now() calls do not fail
    @event.listens_for(engine, "connect")
    def _sqlite_create_now_function(dbapi_connection, connection_record):
        try:
            dbapi_connection.create_function(
                "now", 0, lambda: datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
            )
        except Exception:
            # some DB-APIs may not support create_function; ignore
            pass
else:
    engine = create_engine(
        DATABASE_URL,
        future=True,
        echo=False,
        pool_pre_ping=True,
    )

# (UUID columns in SQLite store strings, no conversion needed)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, future=True)
Base = declarative_base()


def get_db():
    """FastAPI dependency that yields a DB session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()