"""
Database Migration Script
Adds missing columns from Professor-Friendly Grading System changes.
Safe to run multiple times (uses IF NOT EXISTS / column existence checks).
"""
import os
import sys
from pathlib import Path
from dotenv import load_dotenv
import psycopg2

# Load .env from backend directory
dotenv_path = Path(__file__).resolve().parent.parent / "backend" / ".env"
load_dotenv(dotenv_path=dotenv_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not set in .env")
    sys.exit(1)

print(f"Connecting to database...")
conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()


def column_exists(table, column):
    cur.execute("""
        SELECT 1 FROM information_schema.columns
        WHERE table_name=%s AND column_name=%s
    """, (table, column))
    return cur.fetchone() is not None


def table_exists(table):
    cur.execute("""
        SELECT 1 FROM information_schema.tables
        WHERE table_name=%s AND table_schema='public'
    """, (table,))
    return cur.fetchone() is not None


print("\n=== Running Database Migrations ===\n")

# ───── SECTIONS ─────
if table_exists("sections"):
    print("[sections]")
    if not column_exists("sections", "subject_id"):
        print("  + Adding subject_id column...")
        cur.execute("ALTER TABLE sections ADD COLUMN subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE")
    else:
        print("  ✓ subject_id already exists")

    if not column_exists("sections", "section_label"):
        print("  + Adding section_label column...")
        cur.execute("ALTER TABLE sections ADD COLUMN section_label VARCHAR DEFAULT '' NOT NULL")
    else:
        print("  ✓ section_label already exists")

    if not column_exists("sections", "room_number"):
        print("  + Adding room_number column...")
        cur.execute("ALTER TABLE sections ADD COLUMN room_number VARCHAR DEFAULT '' NOT NULL")
    else:
        print("  ✓ room_number already exists")

    # Migrate old name -> section_label if name exists but section_label is empty
    if column_exists("sections", "name") and column_exists("sections", "section_label"):
        print("  + Migrating name -> section_label...")
        cur.execute("UPDATE sections SET section_label = name WHERE section_label = '' AND name IS NOT NULL")
    
    # Drop old columns if they still exist
    for old_col in ["name", "course", "year_level"]:
        if column_exists("sections", old_col):
            print(f"  - Dropping old column: {old_col}")
            cur.execute(f"ALTER TABLE sections DROP COLUMN {old_col}")
else:
    print("[sections] table does not exist")

# ───── STUDENTS ─────
if table_exists("students"):
    print("\n[students]")
    if not column_exists("students", "section_id"):
        print("  + Adding section_id column...")
        cur.execute("ALTER TABLE students ADD COLUMN section_id UUID REFERENCES sections(id) ON DELETE SET NULL")
    else:
        print("  ✓ section_id already exists")
else:
    print("\n[students] table does not exist")

# ───── EXAMS ─────
if table_exists("exams"):
    print("\n[exams]")
    if not column_exists("exams", "term_id"):
        print("  + Adding term_id column...")
        cur.execute("ALTER TABLE exams ADD COLUMN term_id UUID REFERENCES academic_terms(id) ON DELETE SET NULL")
    else:
        print("  ✓ term_id already exists")

    # Rename exam_type -> component_type
    if column_exists("exams", "exam_type") and not column_exists("exams", "component_type"):
        print("  + Renaming exam_type -> component_type...")
        cur.execute("ALTER TABLE exams RENAME COLUMN exam_type TO component_type")
    elif column_exists("exams", "component_type"):
        print("  ✓ component_type already exists")
        # Drop old if both exist
        if column_exists("exams", "exam_type"):
            print("  - Dropping old exam_type column...")
            cur.execute("ALTER TABLE exams DROP COLUMN exam_type")
else:
    print("\n[exams] table does not exist")

# ───── ACADEMIC TERMS ─────
if table_exists("academic_terms"):
    print("\n[academic_terms]")
    if not column_exists("academic_terms", "term_type"):
        print("  + Adding term_type column...")
        cur.execute("ALTER TABLE academic_terms ADD COLUMN term_type VARCHAR DEFAULT 'final' NOT NULL")
    else:
        print("  ✓ term_type already exists")

    if not column_exists("academic_terms", "percentage_weight"):
        print("  + Adding percentage_weight column...")
        cur.execute("ALTER TABLE academic_terms ADD COLUMN percentage_weight INTEGER DEFAULT 33 NOT NULL")
    else:
        print("  ✓ percentage_weight already exists")
else:
    print("\n[academic_terms] table does not exist")

# ───── DONE ─────
cur.close()
conn.close()
print("\n=== Migration Complete! ===")
print("Restart the backend server for changes to take effect.")