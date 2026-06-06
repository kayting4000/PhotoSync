from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# -----------------------
# SQLite DB
# -----------------------
DATABASE_URL = "sqlite:///./photosync.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False
)

Base = declarative_base()


# -----------------------
# DB SESSION
# -----------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -----------------------
# AUTO CREATE TABLES
# (CRITICAL FIX)
# -----------------------
def init_db():
    from models.student import Student
    from models.subject import Subject
    from models.exam import Exam
    from models.exam_result import ExamResult
    from models.section import Section

    Base.metadata.create_all(bind=engine)