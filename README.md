# PhotoSync

A full-stack academic management system for scanning test papers, tracking grades, managing students, and distributing results via email.

## Architecture

| Layer | Technology |
|-------|-----------|
| Web frontend | Next.js 15 + TypeScript + Tailwind CSS |
| Backend API | Python FastAPI + SQLAlchemy |
| Mobile app | Flutter 3 (iOS, Android, Web, Desktop) |
| Database | PostgreSQL (or SQLite for local dev) |
| Auth | JWT |
| Scanner | Roboflow computer vision |
| Email | Gmail SMTP |

## Features

- **Authentication** — JWT-based login/signup for professors and students
- **Student management** — Add, edit, and organise students by subject and section
- **Test paper scanner** — Upload images; automatic check-mark detection via Roboflow
- **Grades & GPA** — Weighted grade calculation, distribution view, export
- **Email reports** — Batch-send grade reports to students via Gmail SMTP
- **Student portal** — Students view their own grades, attendance, and exams
- **Offline support** (Flutter) — Local SQLite cache with background sync

## Project Structure

```
PhotoSync/
├── app/                  # Next.js pages and API routes
├── components/           # React UI components
├── lib/                  # Shared utilities and types
├── backend/              # FastAPI application
│   ├── controllers/      # Route handlers
│   ├── models/           # SQLAlchemy ORM models
│   ├── schemas/          # Pydantic request/response schemas
│   └── main.py           # App entry point
├── flutter_app/          # Flutter mobile/desktop app
│   └── lib/
│       ├── screens/      # UI screens
│       ├── providers/    # State management
│       ├── services/     # API, sync, local DB
│       └── models/       # Dart data models
└── scripts/              # Database migration SQL files
```

## Quick Start

### Backend

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env          # fill in your values
uvicorn main:app --reload
# API docs at http://localhost:8000/docs
```

### Web

```bash
cp .env.local.example .env.local   # fill in NEXT_PUBLIC_API_URL
pnpm install
pnpm dev
# Open http://localhost:3000
```

### Flutter

```bash
cd flutter_app
flutter pub get
# Edit lib/config.dart — set productionUrl or localHost
flutter run
```

## Environment Variables

### Backend (`backend/.env`)

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string (defaults to SQLite) |
| `JWT_SECRET` | Secret key for signing tokens |
| `ROBOFLOW_API_KEY` | Roboflow API key for scanner |
| `ROBOFLOW_WORKSPACE` | Roboflow workspace name |
| `ROBOFLOW_WORKFLOW_ID` | Roboflow workflow ID |
| `GMAIL_USER` | Gmail address for sending emails |
| `GMAIL_PASSWORD` | Gmail App Password |

### Web (`.env.local`)

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_API_URL` | Backend base URL |

> **Never commit `.env` files.** Use the provided `.env.example` templates.

## Database Migrations

SQL migration scripts are in `scripts/`. Run them in order against your PostgreSQL instance:

```bash
psql $DATABASE_URL -f scripts/001_create_tables.sql
psql $DATABASE_URL -f scripts/002_add_user_isolation.sql
# ... and so on
```

## Deployment

- **Backend** — Render, Railway, or any Docker host (`backend/Dockerfile` included)
- **Web** — Vercel (zero-config with Next.js)
- **Mobile** — Standard `flutter build apk` / `flutter build ios`

## License

MIT — see [LICENSE](LICENSE).
