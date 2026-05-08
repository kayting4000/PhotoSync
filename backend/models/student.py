"""
Student model — represents the 'students' table in Supabase (PostgreSQL).

Columns:
  id            uuid  PRIMARY KEY DEFAULT gen_random_uuid()
  student_id    text  UNIQUE NOT NULL
  first_name    text  NOT NULL
  last_name     text  NOT NULL
  email         text
  course        text  NOT NULL
  year_level    int   NOT NULL DEFAULT 1
  created_at    timestamptz DEFAULT now()
"""

TABLE = "students"
