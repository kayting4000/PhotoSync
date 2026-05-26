-- Create sections table and add section_id to students if missing

-- Create sections table
CREATE TABLE IF NOT EXISTS sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  section_label TEXT NOT NULL,
  room_number TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add section_id column to students if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='students' AND column_name='section_id'
  ) THEN
    ALTER TABLE students ADD COLUMN section_id UUID REFERENCES sections(id) ON DELETE SET NULL;
    CREATE INDEX IF NOT EXISTS idx_students_section ON students(section_id);
  END IF;
END
$$;
