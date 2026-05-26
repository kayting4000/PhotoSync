-- Add section_id relationship to student_subjects for section-aware enrollments
ALTER TABLE student_subjects
  ADD COLUMN IF NOT EXISTS section_id UUID REFERENCES sections(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_student_subjects_section ON student_subjects(section_id);
