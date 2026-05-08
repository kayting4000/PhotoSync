"""
Subject model — represents the 'subjects' table in Supabase (PostgreSQL).

Columns:
  id          uuid  PRIMARY KEY DEFAULT gen_random_uuid()
  code        text  UNIQUE NOT NULL
  name        text  NOT NULL
  units       int   NOT NULL DEFAULT 3
  created_at  timestamptz DEFAULT now()
"""

TABLE = "subjects"
