"""
PhotoSync — Neon PostgreSQL Database Configuration
Uses SQLAlchemy ORM with psycopg2 driver.
"""
import os
import re
from pathlib import Path
from dotenv import load_dotenv
from datetime import datetime

from sqlalchemy import create_engine, event
from sqlalchemy.orm import declarative_base, sessionmaker

# Load .env from the backend/ directory explicitly
dotenv_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL") or "sqlite:///./photosync.db"

# Strip unsupported URL parameters that psycopg2 can't parse
DATABASE_URL = re.sub(r'[?&]channel_binding=\w+', '', DATABASE_URL)

# Use special SQLite settings to avoid RETURNING/now() issues and allow multithread access
if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        future=True,
        echo=False,
        pool_pre_ping=True,
        implicit_returning=False,  # prevents SQLAlchemy from using RETURNING which SQLite may not support
    )

    # Provide a now() SQL function in SQLite to emulate Postgres now()
    @event.listens_for(engine, "connect")
    def _sqlite_create_now_function(dbapi_connection, connection_record):
        try:
            # return UTC timestamp compatible with TIMESTAMP fields
            dbapi_connection.create_function("now", 0, lambda: datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"))
        except Exception:
            # some DBAPI implementations may not support create_function; ignore if so
            pass
else:
    engine = create_engine(
        DATABASE_URL,
        future=True,
        echo=False,
        pool_pre_ping=True,
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, future=True)
Base = declarative_base()


def get_db():
    """FastAPI dependency: yields a DB session and closes it after use."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()