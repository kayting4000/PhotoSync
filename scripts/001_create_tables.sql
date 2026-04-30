-- Create students table
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id TEXT NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  course TEXT NOT NULL,
  year_level INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create subjects table
CREATE TABLE IF NOT EXISTS subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  units INTEGER NOT NULL DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create exams table
CREATE TABLE IF NOT EXISTS exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  exam_type TEXT NOT NULL CHECK (exam_type IN ('quiz', 'midterm', 'final', 'assignment')),
  total_items INTEGER NOT NULL,
  points_per_item NUMERIC(5,2) NOT NULL DEFAULT 1,
  passing_score NUMERIC(5,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create exam_results table
CREATE TABLE IF NOT EXISTS exam_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  correct_answers INTEGER NOT NULL DEFAULT 0,
  total_score NUMERIC(10,2) NOT NULL DEFAULT 0,
  percentage NUMERIC(5,2),
  grade TEXT,
  remarks TEXT,
  scanned_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, exam_id)
);

-- Create student_subjects enrollment table
CREATE TABLE IF NOT EXISTS student_subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  semester TEXT NOT NULL,
  academic_year TEXT NOT NULL,
  final_grade NUMERIC(5,2),
  grade_equivalent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, subject_id, semester, academic_year)
);

-- Create scoring_rules table for configurable scoring
CREATE TABLE IF NOT EXISTS scoring_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  section_name TEXT,
  item_start INTEGER NOT NULL DEFAULT 1,
  item_end INTEGER NOT NULL,
  points_per_item NUMERIC(5,2) NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_students_student_id ON students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_course ON students(course);
CREATE INDEX IF NOT EXISTS idx_exam_results_student ON exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_exam ON exam_results(exam_id);
CREATE INDEX IF NOT EXISTS idx_student_subjects_student ON student_subjects(student_id);
CREATE INDEX IF NOT EXISTS idx_student_subjects_subject ON student_subjects(subject_id);
