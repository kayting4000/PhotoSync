from database import Base

# Import all models so Base.metadata knows about every table
from .user import User
from .student import Student
from .subject import Subject
from .exam import Exam
from .exam_result import ExamResult

TABLES = {
    "users": "users",
    "students": "students",
    "subjects": "subjects",
    "exams": "exams",
    "exam_results": "exam_results",
}