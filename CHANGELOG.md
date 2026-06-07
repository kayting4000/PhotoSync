# Changelog

All notable changes to EduScan will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added

#### Backend (Python/FastAPI)
- Hierarchical grade system with Student -> Subject -> Exam levels
- MSU-TCTO grading scale compliance (1.0 - 5.0)
- GPA calculation endpoint (`GET /grades/student/{id}/gpa`)
- Gmail SMTP email integration
- Grade transcript emails with GPA
- Bulk email sending with professional HTML templates
- Student filtering by course, year level, and search
- Scoring rules configuration
- Academic term management
- Semester management
- Attendance tracking
- Exam result management

#### Web Frontend (Next.js)
- Dashboard with statistics overview
- Student management (CRUD)
- Subject management with units
- Test paper scanner with check mark detection
- Grade reports and distributions
- Email grade reports
- Authentication (login/signup)
- Responsive design with shadcn/ui components

#### Mobile App (Flutter)
- Glass morphism UI with neumorphic design
- Smooth hover and press animations (60fps)
- Dark/Light mode support
- Provider-based state management
- Cross-platform support (iOS, Android, Web, Desktop)
- Enhanced color palette with indigo/violet accents
- Optimized animation controllers
- Offline mode with local database
- Push notifications

#### Database
- PostgreSQL schema with Row Level Security
- Student, Subject, Section, Exam tables
- Academic term and semester tables
- GPA configuration tables
- Scoring rule tables
- Migration scripts (001-005)

#### DevOps & Tooling
- GitHub Actions CI/CD pipeline
- Docker containerization
- Docker Compose orchestration
- Makefile with unified commands
- EditorConfig for consistent formatting

#### Documentation
- Comprehensive setup guides
- Backend API documentation
- Flutter deployment guide
- Contributing guidelines
- Code of conduct
- Security policy

### Changed
- Rebranded from PhotoSync to EduScan
- Updated README with correct branding and documentation links
- Pinned backend dependency versions for reproducibility

### Fixed
- Backend import errors
- Scanner `count_objects` parsing
- UUID compatibility issues
- Flutter deprecated API warnings
- Next.js build errors
- Gmail SMTP email sending
- Grade response schema validation
- Section validation issues

---

## [Unreleased]

### Planned
- Unit test suite for backend
- Widget tests for Flutter app
- End-to-end testing
- Performance monitoring
- Multi-language support
- Accessibility improvements

---

*For detailed changes, see individual commit history and documentation files.*