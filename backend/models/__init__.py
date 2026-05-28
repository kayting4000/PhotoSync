from database import Base

# Import all models so Base.metadata knows about every table
from .user import User
from .student import Student
from .subject import Subject
from .exam import Exam
from .exam_result import ExamResult
from .student_subject import StudentSubject
from .scoring_rule import ScoringRule
from .section import Section
from .academic_term import AcademicTerm
from .attendance import Attendance
from .gpa_config import GpaConfig

TABLES = {
    "users": "users",
    "students": "students",
    "subjects": "subjects",
    "exams": "exams",
    "exam_results": "exam_results",
    "student_subjects": "student_subjects",
    "scoring_rules": "scoring_rules",
    "sections": "sections",
    "academic_terms": "academic_terms",
}
