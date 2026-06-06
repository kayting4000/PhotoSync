from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt

# ── palette ──────────────────────────────────────────────
BG      = RGBColor(0x0F, 0x17, 0x2A)   # dark navy
ACCENT  = RGBColor(0x6C, 0x63, 0xFF)   # purple
ACCENT2 = RGBColor(0x00, 0xD4, 0xFF)   # cyan
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)
GRAY    = RGBColor(0xA0, 0xAE, 0xC0)
GREEN   = RGBColor(0x38, 0xBD, 0xF8)

prs = Presentation()
prs.slide_width  = Inches(13.33)
prs.slide_height = Inches(7.5)

BLANK = prs.slide_layouts[6]   # completely blank

# ── helpers ──────────────────────────────────────────────
def bg(slide):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = BG

def box(slide, l, t, w, h, text, size=18, bold=False, color=WHITE,
        align=PP_ALIGN.LEFT, wrap=True, italic=False):
    txb = slide.shapes.add_textbox(Inches(l), Inches(t), Inches(w), Inches(h))
    tf  = txb.text_frame
    tf.word_wrap = wrap
    p   = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size  = Pt(size)
    run.font.bold  = bold
    run.font.color.rgb = color
    run.font.italic = italic
    return txb

def rect(slide, l, t, w, h, color=ACCENT, alpha=None):
    from pptx.util import Inches
    shp = slide.shapes.add_shape(1, Inches(l), Inches(t), Inches(w), Inches(h))
    shp.fill.solid()
    shp.fill.fore_color.rgb = color
    shp.line.fill.background()
    return shp

def accent_bar(slide, y=1.15, w=13.33):
    rect(slide, 0, y, w, 0.04, ACCENT)

def chip(slide, l, t, text, color=ACCENT):
    r = rect(slide, l, t, len(text)*0.13+0.3, 0.35, color)
    box(slide, l+0.08, t+0.02, len(text)*0.13+0.2, 0.32,
        text, size=11, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# SLIDE 1 — Title
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 7.5, RGBColor(0x0A, 0x0F, 0x1E))   # deeper bg
rect(s, 0, 2.8, 13.33, 0.06, ACCENT)                      # mid bar
rect(s, 0, 2.86, 13.33, 0.03, ACCENT2)

box(s, 1, 0.9, 11, 1.2, "EduScan", size=72, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
box(s, 1, 2.0, 11, 0.7, "Backend API — Milestone 2", size=26, color=ACCENT2, align=PP_ALIGN.CENTER)
box(s, 1, 3.1, 11, 0.6, "FastAPI  ·  MVC Architecture  ·  Supabase PostgreSQL",
    size=16, color=GRAY, align=PP_ALIGN.CENTER, italic=True)

# presenter chips
names = ["Presenter 1", "Presenter 2", "Presenter 3"]
starts = [1.5, 5.0, 8.5]
for n, x in zip(names, starts):
    rect(s, x, 4.2, 2.5, 0.55, RGBColor(0x1E, 0x29, 0x4A))
    box(s, x+0.1, 4.28, 2.3, 0.4, n, size=13, color=WHITE, align=PP_ALIGN.CENTER)

box(s, 1, 5.2, 11, 0.4, "CCC151  |  Milestone 2 Presentation", size=12,
    color=GRAY, align=PP_ALIGN.CENTER, italic=True)

# ═══════════════════════════════════════════════════════════
# SLIDE 2 — Tech Stack & Architecture
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 1.1, RGBColor(0x1A, 0x22, 0x3A))
box(s, 0.5, 0.18, 12, 0.7, "Tech Stack & Architecture", size=30, bold=True, color=WHITE)
accent_bar(s, 1.1)

# left column — stack
box(s, 0.5, 1.3, 5.5, 0.45, "🛠  Stack", size=16, bold=True, color=ACCENT2)
items = [
    ("FastAPI", "Web framework + auto Swagger /docs"),
    ("Pydantic v2", "Request / response validation (Views)"),
    ("httpx", "Async HTTP client → Supabase REST"),
    ("Supabase", "PostgreSQL database + Auth"),
    ("python-dotenv", "Environment variable management"),
]
for i, (k, v) in enumerate(items):
    y = 1.8 + i*0.55
    rect(s, 0.5, y, 5.8, 0.45, RGBColor(0x1E, 0x29, 0x4A))
    box(s, 0.65, y+0.05, 1.5, 0.38, k, size=12, bold=True, color=ACCENT)
    box(s, 2.2, y+0.05, 4.0, 0.38, v, size=12, color=GRAY)

# right column — MVC diagram
box(s, 7.0, 1.3, 5.5, 0.45, "🏗  MVC Flow", size=16, bold=True, color=ACCENT2)
layers = [
    (ACCENT,  "MODELS",      "models/  — table definitions (Supabase schema)"),
    (GREEN,   "VIEWS",       "schemas/ — Pydantic request/response models"),
    (RGBColor(0xFF,0x6B,0x6B), "CONTROLLERS", "controllers/ — APIRouter endpoints + logic"),
]
for i, (c, label, desc) in enumerate(layers):
    y = 1.85 + i * 1.3
    rect(s, 7.0, y, 5.8, 0.5, c)
    box(s, 7.1, y+0.06, 1.6, 0.4, label, size=13, bold=True, color=WHITE)
    box(s, 8.8, y+0.06, 3.9, 0.4, desc, size=11, color=WHITE)
    if i < 2:
        box(s, 9.6, y+0.55, 1.5, 0.4, "▼", size=18, color=GRAY, align=PP_ALIGN.CENTER)

box(s, 7.0, 5.6, 5.8, 0.4,
    "Request → Controller → Model (DB) → Schema → Response",
    size=11, color=GRAY, italic=True)

# ═══════════════════════════════════════════════════════════
# SLIDE 3 — Database Schema
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 1.1, RGBColor(0x1A, 0x22, 0x3A))
box(s, 0.5, 0.18, 12, 0.7, "Database Schema", size=30, bold=True, color=WHITE)
accent_bar(s, 1.1)

tables = [
    ("students", ["id (uuid PK)", "student_id (unique)", "first_name, last_name",
                  "email, course", "year_level (int)", "created_at"]),
    ("subjects", ["id (uuid PK)", "code (unique)", "name",
                  "units (int)", "created_at"]),
    ("exams",    ["id (uuid PK)", "subject_id → subjects", "name, exam_type",
                  "total_items, points_per_item", "passing_score", "created_at"]),
    ("exam_results", ["id (uuid PK)", "student_id → students",
                      "exam_id → exams", "correct_answers, total_score",
                      "percentage, grade, remarks", "scanned_image_url"]),
]
cols = [0.3, 3.55, 6.8, 10.05]
for i, (tname, fields) in enumerate(tables):
    x = cols[i]
    rect(s, x, 1.25, 2.9, 0.45, ACCENT)
    box(s, x+0.1, 1.3, 2.7, 0.38, tname, size=13, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    for j, f in enumerate(fields):
        yy = 1.75 + j*0.42
        bg_c = RGBColor(0x1A,0x22,0x3A) if j%2==0 else RGBColor(0x16,0x1D,0x33)
        rect(s, x, yy, 2.9, 0.4, bg_c)
        box(s, x+0.12, yy+0.05, 2.7, 0.34, f, size=10, color=GRAY)

box(s, 0.3, 6.9, 12.7, 0.4,
    "All tables hosted on Supabase (PostgreSQL) · Row Level Security enabled · UUID primary keys",
    size=11, color=GRAY, italic=True, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# SLIDE 4 — API Endpoints (CRUD)
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 1.1, RGBColor(0x1A, 0x22, 0x3A))
box(s, 0.5, 0.18, 12, 0.7, "API Endpoints — Full CRUD", size=30, bold=True, color=WHITE)
accent_bar(s, 1.1)

METHOD_COLORS = {
    "GET":    RGBColor(0x22, 0xC5, 0x5E),
    "POST":   RGBColor(0x38, 0xBD, 0xF8),
    "PUT":    RGBColor(0xFB, 0xBF, 0x24),
    "DELETE": RGBColor(0xF8, 0x71, 0x71),
}

endpoints = [
    # (method, path, description)
    ("GET",    "/students/",          "List all students"),
    ("POST",   "/students/",          "Create student (validated)"),
    ("PUT",    "/students/{id}",      "Update student fields"),
    ("DELETE", "/students/{id}",      "Remove student"),
    ("GET",    "/subjects/",          "List all subjects"),
    ("POST",   "/subjects/",          "Create subject"),
    ("PUT",    "/subjects/{id}",      "Update subject"),
    ("DELETE", "/subjects/{id}",      "Remove subject"),
    ("GET",    "/exams/",             "List exams (filter by subject)"),
    ("POST",   "/exams/",             "Create exam"),
    ("DELETE", "/exams/{id}",         "Remove exam"),
    ("GET",    "/results/",           "List exam results"),
    ("POST",   "/results/",           "Submit scan result"),
    ("GET",    "/grades/",            "Aggregated grade report"),
    ("GET",    "/dashboard/stats",    "Dashboard statistics"),
    ("POST",   "/auth/login",         "User login → JWT token"),
]

per_col = 8
for i, (method, path, desc) in enumerate(endpoints):
    col = i // per_col
    row = i %  per_col
    x = 0.3 + col * 6.5
    y = 1.25 + row * 0.65
    rect(s, x, y, 6.1, 0.55, RGBColor(0x1A, 0x22, 0x3A))
    # method badge
    rect(s, x, y, 1.0, 0.55, METHOD_COLORS.get(method, ACCENT))
    box(s, x+0.02, y+0.1, 0.96, 0.36, method, size=11, bold=True,
        color=WHITE, align=PP_ALIGN.CENTER)
    box(s, x+1.05, y+0.05, 2.5, 0.24, path, size=10, bold=True, color=WHITE)
    box(s, x+1.05, y+0.28, 2.5, 0.22, desc, size=9, color=GRAY)

box(s, 0.3, 6.85, 12.7, 0.4,
    "All endpoints auto-documented at  http://localhost:8000/docs  (Swagger UI)",
    size=12, color=ACCENT2, italic=True, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# SLIDE 5 — Code Walkthrough (key snippets)
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 1.1, RGBColor(0x1A, 0x22, 0x3A))
box(s, 0.5, 0.18, 12, 0.7, "Code Walkthrough", size=30, bold=True, color=WHITE)
accent_bar(s, 1.1)

snippets = [
    ("Model  (models/student.py)", 'TABLE = "students"\n# Supabase PostgreSQL table\n# id, student_id, first_name,\n# last_name, email, course,\n# year_level, created_at'),
    ("Schema / View  (schemas/student.py)", 'class StudentCreate(BaseModel):\n    student_id: str\n    first_name: str\n    last_name:  str\n    email:      Optional[str]\n    course:     str\n    year_level: int = 1'),
    ("Controller  (controllers/students.py)", '@router.post("/students/")\nasync def create_student(\n    body: StudentCreate\n):\n    res = await client.post(\n        rest_url(TABLE),\n        json=body.model_dump()\n    )\n    return res.json()[0]'),
]

xs = [0.3, 4.55, 8.8]
for i, (title, code) in enumerate(snippets):
    x = xs[i]
    rect(s, x, 1.25, 4.1, 0.4, ACCENT)
    box(s, x+0.1, 1.28, 3.9, 0.35, title, size=11, bold=True, color=WHITE)
    rect(s, x, 1.65, 4.1, 4.8, RGBColor(0x0D, 0x13, 0x21))
    box(s, x+0.15, 1.72, 3.85, 4.65, code, size=10.5, color=GREEN,
        italic=False, wrap=True)

box(s, 0.3, 6.7, 12.7, 0.5,
    "Strict separation: Models define tables · Schemas validate I/O · Controllers handle HTTP logic",
    size=12, color=GRAY, italic=True, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# SLIDE 6 — Setup & Demo
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 1.1, RGBColor(0x1A, 0x22, 0x3A))
box(s, 0.5, 0.18, 12, 0.7, "Setup & Live Demo", size=30, bold=True, color=WHITE)
accent_bar(s, 1.1)

# left — setup steps
box(s, 0.5, 1.3, 5.5, 0.4, "⚡  Quick Setup", size=16, bold=True, color=ACCENT2)
steps = [
    ("1", "cd backend"),
    ("2", "pip install -r requirements.txt"),
    ("3", "Add .env  →  SUPABASE_URL + SUPABASE_KEY"),
    ("4", "uvicorn main:app --reload"),
    ("5", "Open  http://localhost:8000/docs"),
    ("6", "python test_api.py  (verify all endpoints)"),
]
for i, (num, cmd) in enumerate(steps):
    y = 1.8 + i * 0.72
    rect(s, 0.5, y, 0.45, 0.52, ACCENT)
    box(s, 0.5, y+0.08, 0.45, 0.38, num, size=14, bold=True,
        color=WHITE, align=PP_ALIGN.CENTER)
    rect(s, 1.0, y, 5.3, 0.52, RGBColor(0x1A, 0x22, 0x3A))
    box(s, 1.1, y+0.1, 5.1, 0.36, cmd, size=12, color=WHITE)

# right — what to demo
box(s, 7.2, 1.3, 5.5, 0.4, "🎯  Demo Checklist", size=16, bold=True, color=ACCENT2)
checks = [
    "✅  Swagger UI at /docs",
    "✅  POST /students/ — create with validation",
    "✅  GET  /students/ — list all",
    "✅  PUT  /students/{id} — update",
    "✅  DELETE /students/{id} — remove",
    "✅  POST /results/ — submit exam scan",
    "✅  GET  /grades/ — aggregated report",
    "✅  python test_api.py — automated test",
]
for i, c in enumerate(checks):
    y = 1.8 + i * 0.6
    rect(s, 7.2, y, 5.8, 0.5, RGBColor(0x1A, 0x22, 0x3A) if i%2==0 else RGBColor(0x16,0x1D,0x33))
    box(s, 7.35, y+0.08, 5.5, 0.36, c, size=12, color=WHITE)

box(s, 0.3, 6.85, 12.7, 0.4,
    "Repository includes README.md · requirements.txt · test_api.py",
    size=12, color=GRAY, italic=True, align=PP_ALIGN.CENTER)

# ═══════════════════════════════════════════════════════════
# SLIDE 7 — Summary
# ═══════════════════════════════════════════════════════════
s = prs.slides.add_slide(BLANK); bg(s)
rect(s, 0, 0, 13.33, 7.5, RGBColor(0x0A, 0x0F, 0x1E))
rect(s, 0, 2.9, 13.33, 0.06, ACCENT)
rect(s, 0, 2.96, 13.33, 0.03, ACCENT2)

box(s, 1, 0.5, 11, 1.0, "Milestone 2 — Delivered ✅", size=36, bold=True,
    color=WHITE, align=PP_ALIGN.CENTER)

bullets = [
    ("🏗", "MVC Architecture",    "models/ · schemas/ · controllers/"),
    ("⚡", "FastAPI + Pydantic",   "Auto-validation, async endpoints, Swagger /docs"),
    ("🗄", "Supabase PostgreSQL",  "4 tables, UUID PKs, RLS, relational FKs"),
    ("🔄", "Full CRUD",            "Students · Subjects · Exams · Results"),
    ("🧪", "Test Script",          "test_api.py verifies all endpoints"),
    ("📄", "README",               "Setup, install, run instructions included"),
]
xs2 = [0.6, 6.8]
for i, (icon, title, desc) in enumerate(bullets):
    col = i % 2
    row = i // 2
    x = xs2[col]
    y = 1.7 + row * 1.1
    rect(s, x, y, 5.9, 0.85, RGBColor(0x1A, 0x22, 0x3A))
    box(s, x+0.12, y+0.08, 0.5, 0.7, icon, size=20, align=PP_ALIGN.CENTER)
    box(s, x+0.7, y+0.05, 2.2, 0.35, title, size=13, bold=True, color=ACCENT2)
    box(s, x+0.7, y+0.38, 5.0, 0.38, desc, size=11, color=GRAY)

box(s, 1, 5.1, 11, 0.5, "Thank you!", size=28, bold=True,
    color=WHITE, align=PP_ALIGN.CENTER)
box(s, 1, 5.65, 11, 0.4, "Questions?", size=18, color=GRAY, align=PP_ALIGN.CENTER)

# ── save ─────────────────────────────────────────────────
out = r"d:\CCC151\test paper\EduScan_Backend_Milestone2.pptx"
prs.save(out)
print(f"Saved: {out}")
