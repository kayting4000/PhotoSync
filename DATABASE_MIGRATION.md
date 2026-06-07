# Database Migration Guide - Professor-Friendly Grading System

## Overview

This migration updates the PhotoSync database schema to support the new professor-friendly grading system with weighted terms and exam components.

## Changes Summary

1. **Sections Table**: Removed `course` and `year_level` columns (rooms only)
2. **Academic Terms Table**: Added `term_type` and `percentage_weight` columns  
3. **Exams Table**: Renamed `exam_type` to `component_type`

## Migration Scripts

### Option 1: Fresh Database (New Deployment)

If starting fresh, the migrations will run automatically on first startup via SQLAlchemy's `Base.metadata.create_all()`.

No action needed - tables will be created with the new schema.

### Option 2: Existing Database Migration

Run these SQL commands on your Neon PostgreSQL database:

```sql
-- Step 1: Remove unused columns from sections table
ALTER TABLE sections DROP COLUMN IF EXISTS course;
ALTER TABLE sections DROP COLUMN IF EXISTS year_level;

-- Step 2: Add new columns to academic_terms table
ALTER TABLE academic_terms 
  ADD COLUMN IF NOT EXISTS term_type VARCHAR DEFAULT 'preliminary',
  ADD COLUMN IF NOT EXISTS percentage_weight INTEGER DEFAULT 33;

-- Step 3: Rename exam_type to component_type
ALTER TABLE exams 
  RENAME COLUMN exam_type TO component_type;

-- Step 4: Add constraints to validate percentage_weight
ALTER TABLE academic_terms 
  ADD CONSTRAINT check_percentage_weight 
  CHECK (percentage_weight >= 10 AND percentage_weight <= 90);

-- Step 5: Update existing exams to have valid component_type values
UPDATE exams SET component_type = 'exam' WHERE component_type IS NULL OR component_type = '';
```

### Option 3: Using Alembic (Recommended for Production)

If you want to use Alembic for version control of migrations:

1. Create a new migration:
```bash
cd backend
alembic revision --autogenerate -m "add_professor_grading_system"
```

2. Review the generated migration file in `alembic/versions/`

3. Apply the migration:
```bash
alembic upgrade head
```

## Validation After Migration

### 1. Verify Sections Table

```sql
SELECT * FROM information_schema.columns 
WHERE table_name = 'sections' 
ORDER BY ordinal_position;
```

Should show columns: `id`, `user_id`, `name`, `created_at`

### 2. Verify Academic Terms Table

```sql
SELECT * FROM information_schema.columns 
WHERE table_name = 'academic_terms' 
ORDER BY ordinal_position;
```

Should show columns: `id`, `user_id`, `name`, `term_type`, `percentage_weight`, `start_date`, `end_date`, `is_current`, `created_at`

### 3. Verify Exams Table

```sql
SELECT * FROM information_schema.columns 
WHERE table_name = 'exams' 
WHERE column_name IN ('exam_type', 'component_type');
```

Should show only `component_type` column (not `exam_type`)

### 4. Check Constraints

```sql
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE table_name = 'academic_terms';
```

Should include `check_percentage_weight` constraint

## Data Migration Examples

### Example 1: Update Existing Sections

If your sections had course/year_level data:

```sql
-- Before migration, you might have:
-- name: 'BSIT-3A', course: 'BSIT', year_level: 3

-- After migration, just room reference:
-- name: 'Room 101'

-- Manual update example:
UPDATE sections 
SET name = CONCAT('Room ', name) 
WHERE name NOT LIKE 'Room %';
```

### Example 2: Update Existing Academic Terms

```sql
-- Update all existing terms to have term_type and percentage_weight
UPDATE academic_terms 
SET term_type = 'preliminary', percentage_weight = 33 
WHERE term_type IS NULL OR term_type = '';

-- Manually assign term types based on dates if needed
UPDATE academic_terms 
SET term_type = 'mid-semester' 
WHERE name LIKE '%Mid%' OR name LIKE '%mid%';

UPDATE academic_terms 
SET term_type = 'final' 
WHERE name LIKE '%Final%' OR name LIKE '%final%';
```

### Example 3: Check Exam Component Types

```sql
-- Before migration, you might have exam_type values like:
-- 'midterm', 'final', 'quiz', 'homework'

-- Map them to component_type:
-- 'midterm' or 'final' → 'exam'
-- 'quiz' → 'quiz'
-- 'homework' or 'assignment' → 'assignment'
-- 'presentation' or 'recitation' → 'oral'

UPDATE exams 
SET component_type = 'exam' 
WHERE component_type IN ('midterm', 'final');

UPDATE exams 
SET component_type = 'assignment' 
WHERE component_type IN ('homework');

UPDATE exams 
SET component_type = 'oral' 
WHERE component_type IN ('presentation', 'recitation');
```

## Rollback Instructions (If Needed)

If you need to revert the migration:

```sql
-- Add back the removed columns (with default values)
ALTER TABLE sections 
  ADD COLUMN course VARCHAR DEFAULT 'General',
  ADD COLUMN year_level INTEGER DEFAULT 1;

-- Remove the new columns
ALTER TABLE academic_terms 
  DROP COLUMN IF EXISTS term_type,
  DROP COLUMN IF EXISTS percentage_weight;

-- Rename component_type back to exam_type
ALTER TABLE exams 
  RENAME COLUMN component_type TO exam_type;

-- Remove the constraint
ALTER TABLE academic_terms 
  DROP CONSTRAINT IF EXISTS check_percentage_weight;
```

## Backend Code Updates

The backend models have been updated:

### Section Model
```python
# Old
Section(
    name="BSIT-3A",
    course="BSIT",
    year_level=3
)

# New
Section(
    name="Room 101"  # Just room number
)
```

### AcademicTerm Model
```python
# Old
AcademicTerm(
    name="AY 2025-2026, 1st Semester",
    start_date=date(2025, 8, 1),
    end_date=date(2025, 12, 20),
    is_current=True
)

# New
AcademicTerm(
    name="Preliminary Term",
    term_type="preliminary",
    percentage_weight=30,
    start_date=date(2026, 1, 15),
    end_date=date(2026, 2, 28),
    is_current=True
)
```

### Exam Model
```python
# Old
Exam(
    name="Midterm Exam",
    exam_type="midterm",
    ...
)

# New
Exam(
    name="Midterm Exam",
    component_type="exam",  # Now 'exam', 'quiz', 'assignment', 'oral'
    ...
)
```

## API Endpoint Updates

### Creating a Section

```bash
# Old
POST /sections/
{
  "name": "BSIT-3A",
  "course": "BSIT",
  "year_level": 3
}

# New
POST /sections/
{
  "name": "Room 101"
}
```

### Creating an Academic Term

```bash
# Old
POST /academic-terms/
{
  "name": "AY 2025-2026, 1st Semester",
  "start_date": "2025-08-01",
  "end_date": "2025-12-20",
  "is_current": true
}

# New
POST /academic-terms/
{
  "name": "Preliminary Term",
  "term_type": "preliminary",
  "percentage_weight": 30,
  "start_date": "2026-01-15",
  "end_date": "2026-02-28",
  "is_current": true
}
```

### Creating an Exam

```bash
# Old
POST /exams/
{
  "subject_id": "uuid",
  "name": "Midterm Exam",
  "exam_type": "midterm",
  ...
}

# New
POST /exams/
{
  "subject_id": "uuid",
  "name": "Midterm Exam",
  "component_type": "exam",  # exam, quiz, assignment, oral
  ...
}
```

### New Endpoint: Weighted Term Grades

```bash
GET /gpa/weighted/?student_id=uuid&subject_id=uuid

Response:
{
  "final_grade": 87.8,
  "term_scores": {
    "term-id": {
      "term_name": "Preliminary Term",
      "term_type": "preliminary",
      "percentage_weight": 30,
      "average_score": 85
    }
  },
  "total_weight": 100
}
```

## Testing After Migration

### 1. Test Backend Startup

```bash
cd backend
python -m uvicorn main:app --reload
```

Should start without errors. Tables should be accessible at http://localhost:8000/docs

### 2. Test Section Creation

```bash
curl -X POST http://localhost:8000/sections/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Room 101"}'
```

### 3. Test Academic Term Creation

```bash
curl -X POST http://localhost:8000/academic-terms/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Preliminary Term",
    "term_type": "preliminary",
    "percentage_weight": 30,
    "start_date": "2026-01-15",
    "end_date": "2026-02-28",
    "is_current": true
  }'
```

### 4. Test Weighted Grades

```bash
curl -X GET "http://localhost:8000/gpa/weighted/?student_id=STUDENT_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Environment Variables

No new environment variables needed. The system uses existing configuration.

## Troubleshooting

### Issue: Column already exists error

```
ERROR: column "term_type" of relation "academic_terms" already exists
```

**Solution**: The migration has already been applied. Skip this step.

### Issue: Constraint violation

```
ERROR: new row for relation "academic_terms" violates check constraint "check_percentage_weight"
```

**Solution**: Ensure all `percentage_weight` values are between 10 and 90.

```sql
UPDATE academic_terms 
SET percentage_weight = 33 
WHERE percentage_weight < 10 OR percentage_weight > 90;
```

### Issue: Foreign key constraint violation

```
ERROR: insert or update on table "exams" violates foreign key constraint
```

**Solution**: Ensure all `term_id` values exist in `academic_terms` table.

```sql
-- Check for orphaned records
SELECT * FROM exams WHERE term_id NOT IN (SELECT id FROM academic_terms);

-- Remove orphaned records or update term_id
DELETE FROM exams WHERE term_id NOT IN (SELECT id FROM academic_terms);
```

## Rollback Testing

Before applying to production, test the rollback:

1. Create a test database copy
2. Apply migration
3. Test rollback script
4. Verify data integrity

## Support

For migration issues, check:
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [SQLAlchemy Docs](https://docs.sqlalchemy.org/)
- [Neon Documentation](https://neon.tech/docs/)

---

**Last Updated**: May 23, 2026
**Version**: 1.0
**Status**: Ready for Deployment
