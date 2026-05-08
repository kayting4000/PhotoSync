"""
ExamResult model — represents the 'exam_results' table in Supabase (PostgreSQL).

Columns:
  id                uuid   PRIMARY KEY DEFAULT gen_random_uuid()
  student_id        uuid   REFERENCES students(id)
  exam_id           uuid   REFERENCES exams(id)
  correct_answers   int    NOT NULL
  total_score       float  NOT NULL
  percentage        float
  grade             text
  remarks           text
  scanned_image_url text
  created_at        timestamptz DEFAULT now()
"""

TABLE = "exam_results"
