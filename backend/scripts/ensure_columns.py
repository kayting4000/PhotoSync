"""
Ensure all columns defined in SQLAlchemy models exist in the database.
This runs on startup and adds any missing columns without dropping existing data.
Supports both SQLite and PostgreSQL.
"""
import logging
from sqlalchemy import text, inspect
from database import engine, DATABASE_URL

logger = logging.getLogger(__name__)

# Columns that may have been added after initial table creation.
# Format: (table_name, column_name, column_type_sql)
COLUMNS_TO_ENSURE = [
    ("students", "parent_guardian_email", "VARCHAR"),
]


def column_exists_sqlite(conn, table_name, column_name):
    """Check if column exists in SQLite table."""
    try:
        result = conn.execute(
            text(f"PRAGMA table_info({table_name})")
        )
        columns = result.fetchall()
        return any(col[1] == column_name for col in columns)
    except Exception:
        return False


def column_exists_postgres(conn, table_name, column_name):
    """Check if column exists in PostgreSQL table."""
    try:
        result = conn.execute(
            text(
                "SELECT EXISTS ("
                "  SELECT 1 FROM information_schema.columns"
                "  WHERE table_name = :table AND column_name = :column"
                ")"
            ),
            {"table": table_name, "column": column_name},
        )
        return result.scalar()
    except Exception:
        return False


def ensure_columns():
    """Add any missing columns to existing tables."""
    is_sqlite = DATABASE_URL.startswith("sqlite")
    
    with engine.connect() as conn:
        for table, column, col_type in COLUMNS_TO_ENSURE:
            try:
                # Check if column exists based on database type
                if is_sqlite:
                    exists = column_exists_sqlite(conn, table, column)
                else:
                    exists = column_exists_postgres(conn, table, column)
                
                if not exists:
                    conn.execute(
                        text(f"ALTER TABLE {table} ADD COLUMN {column} {col_type}")
                    )
                    conn.commit()
                    logger.info("Added missing column %s.%s", table, column)
                else:
                    logger.debug("Column %s.%s already exists", table, column)
            except Exception as e:
                logger.error(
                    "Failed to ensure column %s.%s: %s", table, column, e
                )
