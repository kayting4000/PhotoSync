"""
Exam model — represents the 'exams' table in Supabase (PostgreSQL).

Columns:
  id               uuid   PRIMARY KEY DEFAULT gen_random_uuid()
  subject_id       uuid   REFERENCES subjects(id)
  name             text   NOT NULL
  exam_type        text   NOT NULL
  total_items      int    NOT NULL
  points_per_item  float  NOT NULL DEFAULT 1.0
  passing_score    float
  created_at       timestamptz DEFAULT now()
"""

TABLE = "exams"
