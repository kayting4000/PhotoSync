from .auth import router as auth_router, require_role, get_current_user
from .students import router as students_router
from .subjects import router as subjects_router
from .exams import router as exams_router
from .results import router as results_router
from .dashboard import router as dashboard_router
from .grades import router as grades_router
from .scanner import router as scanner_router
from .scan_uploads import router as scan_uploads_router
from .email import router as email_router
from .student_subjects import router as student_subjects_router
from .scoring_rules import router as scoring_rules_router
from .sections import router as sections_router
from .academic_terms import router as academic_terms_router
from .attendance import router as attendance_router
from .gpa_config import router as gpa_config_router
from .student_portal import router as student_portal_router
from .feedback import router as feedback_router
