"""
Ensure all columns defined in SQLAlchemy models exist in the database.
This runs on startup and adds any missing columns without dropping existing data.
"""
import logging
from sqlalchemy import text
from database import engine

logger = logging.getLogger(__name__)

# Columns that may have been added after initial table creation.
# Format: (table_name, column_name, column_type_sql)
COLUMNS_TO_ENSURE = [
    ("students", "parent_guardian_email", "VARCHAR"),
]


def ensure_columns():
    """Add any missing columns to existing tables."""
    with engine.connect() as conn:
        for table, column, col_type in COLUMNS_TO_ENSURE:
            try:
                # Check if column exists
                result = conn.execute(
                    text(
                        "SELECT EXISTS ("
                        "  SELECT 1 FROM information_schema.columns"
                        "  WHERE table_name = :table AND column_name = :column"
                        ")"
                    ),
                    {"table": table, "column": column},
                )
                exists = result.scalar()
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