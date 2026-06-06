from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

BG     = RGBColor(0x0F,0x17,0x2A)
DARK   = RGBColor(0x0A,0x0F,0x1E)
CARD   = RGBColor(0x1A,0x22,0x3A)
CARD2  = RGBColor(0x16,0x1D,0x33)
ACCENT = RGBColor(0x6C,0x63,0xFF)
CYAN   = RGBColor(0x00,0xD4,0xFF)
GREEN  = RGBColor(0x38,0xBD,0xF8)
WHITE  = RGBColor(0xFF,0xFF,0xFF)
GRAY   = RGBColor(0xA0,0xAE,0xC0)
RED    = RGBColor(0xF8,0x71,0x71)
YELLOW = RGBColor(0xFB,0xBF,0x24)
MGREEN = RGBColor(0x22,0xC5,0x5E)

prs = Presentation()
prs.slide_width  = Inches(13.33)
prs.slide_height = Inches(7.5)
BLANK = prs.slide_layouts[6]

def bg(slide, color=BG):
    f = slide.background.fill; f.solid(); f.fore_color.rgb = color

def box(slide, l, t, w, h, text, size=14, bold=False, color=WHITE,
        align=PP_ALIGN.LEFT, italic=False):
    tb = slide.shapes.add_textbox(Inches(l),Inches(t),Inches(w),Inches(h))
    tf = tb.text_frame; tf.word_wrap = True
    p  = tf.paragraphs[0]; p.alignment = align
    r  = p.add_run(); r.text = text
    r.font.size=Pt(size); r.font.bold=bold
    r.font.color.rgb=color; r.font.italic=italic
    return tb

def rect(slide, l, t, w, h, color=ACCENT):
    s = slide.shapes.add_shape(1,Inches(l),Inches(t),Inches(w),Inches(h))
    s.fill.solid(); s.fill.fore_color.rgb=color; s.line.fill.background()
    return s

def header(slide, title):
    rect(slide,0,0,13.33,1.1,CARD)
    box(slide,0.5,0.2,12,0.7,title,size=28,bold=True,color=WHITE)
    rect(slide,0,1.1,13.33,0.05,ACCENT)
    rect(slide,0,1.15,13.33,0.03,CYAN)

def method_badge(slide, x, y, method):
    colors = {"GET":MGREEN,"POST":CYAN,"PUT":YELLOW,"DELETE":RED}
    c = colors.get(method, ACCENT)
    rect(slide,x,y,0.95,0.48,c)
    box(slide,x,y+0.1,0.95,0.3,method,size=10,bold=True,color=WHITE,align=PP_ALIGN.CENTER)

# ── SLIDE 1: Title ─────────────────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s, DARK)
rect(s,0,3.0,13.33,0.07,ACCENT)
rect(s,0,3.07,13.33,0.04,CYAN)
box(s,1,0.7,11,1.3,"EduScan",size=72,bold=True,color=WHITE,align=PP_ALIGN.CENTER)
box(s,1,2.0,11,0.7,"Backend API — Milestone 2",size=26,color=CYAN,align=PP_ALIGN.CENTER)
box(s,1,3.3,11,0.55,"FastAPI  ·  MVC Architecture  ·  Supabase PostgreSQL  ·  MSU-Tawi-Tawi",
    size=15,color=GRAY,align=PP_ALIGN.CENTER,italic=True)

for i,(name,role) in enumerate([
    ("Presenter 1","Framework & Architecture"),
    ("Presenter 2","Endpoints & Models"),
    ("Presenter 3","Demo & Testing"),
]):
    x = 1.0 + i*4.0
    rect(s,x,4.1,3.5,0.9,CARD)
    rect(s,x,4.1,3.5,0.08,ACCENT)
    box(s,x+0.15,4.2,3.2,0.38,name,size=14,bold=True,color=WHITE)
    box(s,x+0.15,4.55,3.2,0.35,role,size=11,color=GRAY,italic=True)

box(s,1,5.5,11,0.4,"CCC151  |  Milestone 2",size=12,color=GRAY,align=PP_ALIGN.CENTER,italic=True)

# ── SLIDE 2: MVC Architecture ──────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"MVC Architecture")

# left: folder structure
box(s,0.4,1.3,4.5,0.4,"Project Structure",size=14,bold=True,color=CYAN)
code = (
    "backend/\n"
    "  main.py          # app entry point\n"
    "  database.py      # Supabase connection\n"
    "  requirements.txt\n"
    "  test_api.py\n"
    "  models/          # M - table schemas\n"
    "    student.py\n"
    "    subject.py\n"
    "    exam.py\n"
    "    exam_result.py\n"
    "  schemas/         # V - Pydantic models\n"
    "    student.py\n"
    "    exam_result.py\n"
    "    auth.py  ...\n"
    "  controllers/     # C - route handlers\n"
    "    students.py\n"
    "    subjects.py\n"
    "    exams.py\n"
    "    results.py\n"
    "    grades.py  ..."
)
rect(s,0.4,1.75,4.6,5.4,CARD2)
box(s,0.55,1.85,4.35,5.2,code,size=9.5,color=GREEN)

# right: MVC flow boxes
box(s,5.8,1.3,7.0,0.4,"Request Flow",size=14,bold=True,color=CYAN)
layers = [
    (ACCENT,  "MODELS",      "models/",      "Define table names & column schemas\nMaps to Supabase PostgreSQL tables"),
    (MGREEN,  "VIEWS",       "schemas/",     "Pydantic BaseModel classes\nValidate & serialize request/response data"),
    (RED,     "CONTROLLERS", "controllers/", "APIRouter endpoints\nHandle HTTP logic, call DB, return response"),
]
for i,(c,label,path,desc) in enumerate(layers):
    y = 1.85 + i*1.6
    rect(s,5.8,y,7.1,1.35,CARD)
    rect(s,5.8,y,0.35,1.35,c)
    box(s,6.25,y+0.08,2.0,0.45,label,size=14,bold=True,color=WHITE)
    box(s,6.25,y+0.5,1.5,0.3,path,size=10,color=c,italic=True)
    box(s,8.3,y+0.1,4.4,1.1,desc,size=11,color=GRAY)
    if i<2:
        box(s,9.1,y+1.38,1.5,0.3,"v",size=14,bold=True,color=GRAY,align=PP_ALIGN.CENTER)

box(s,5.8,6.75,7.1,0.4,
    "HTTP Request  ->  Controller  ->  Model  ->  Schema  ->  Response",
    size=11,color=GRAY,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 3: Database Schema ───────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"Database Schema  (Supabase PostgreSQL)")

tables = [
    ("students",[
        "id          uuid  PK",
        "student_id  text  UNIQUE",
        "first_name  text",
        "last_name   text",
        "email       text",
        "course      text",
        "year_level  int",
        "created_at  timestamptz",
    ]),
    ("subjects",[
        "id          uuid  PK",
        "code        text  UNIQUE",
        "name        text",
        "units       int",
        "created_at  timestamptz",
    ]),
    ("exams",[
        "id               uuid  PK",
        "subject_id       uuid  FK->subjects",
        "name             text",
        "exam_type        text",
        "total_items      int",
        "points_per_item  float",
        "passing_score    float",
        "created_at       timestamptz",
    ]),
    ("exam_results",[
        "id               uuid  PK",
        "student_id       uuid  FK->students",
        "exam_id          uuid  FK->exams",
        "correct_answers  int",
        "total_score      float",
        "percentage       float",
        "grade            text  (MSU scale)",
        "grade_point      float",
        "remarks          text",
        "scanned_image_url text",
    ]),
]

xs = [0.3,3.55,6.8,10.05]
for i,(tname,fields) in enumerate(tables):
    x = xs[i]
    rect(s,x,1.3,3.0,0.45,ACCENT)
    box(s,x+0.1,1.33,2.8,0.38,tname,size=12,bold=True,color=WHITE,align=PP_ALIGN.CENTER)
    for j,f in enumerate(fields):
        yy = 1.78+j*0.48
        rect(s,x,yy,3.0,0.45,CARD if j%2==0 else CARD2)
        box(s,x+0.12,yy+0.07,2.8,0.34,f,size=9,color=GRAY)

box(s,0.3,6.88,12.7,0.38,
    "Row Level Security (RLS) enabled  |  UUID primary keys  |  Foreign key relationships enforced",
    size=11,color=GRAY,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 4: API Endpoints ─────────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"API Endpoints — Full CRUD")

endpoints = [
    ("POST",  "/auth/signup",        "Register new user"),
    ("POST",  "/auth/login",         "Login -> JWT token"),
    ("GET",   "/students/",          "List all students"),
    ("POST",  "/students/",          "Create student (validated)"),
    ("PUT",   "/students/{id}",      "Update student"),
    ("DELETE","/students/{id}",      "Delete student"),
    ("GET",   "/subjects/",          "List all subjects"),
    ("POST",  "/subjects/",          "Create subject"),
    ("PUT",   "/subjects/{id}",      "Update subject"),
    ("DELETE","/subjects/{id}",      "Delete subject"),
    ("GET",   "/exams/",             "List exams (?subject_id=)"),
    ("POST",  "/exams/",             "Create exam"),
    ("DELETE","/exams/{id}",         "Delete exam"),
    ("GET",   "/results/",           "List results (?student_id=)"),
    ("POST",  "/results/",           "Submit scan + auto-grade"),
    ("DELETE","/results/{id}",       "Delete result"),
    ("GET",   "/gpa/",               "Weighted GPA (?student_id=)"),
    ("GET",   "/dashboard/",         "Stats overview"),
]

per_col = 9
for i,(method,path,desc) in enumerate(endpoints):
    col = i // per_col
    row = i %  per_col
    x = 0.3 + col*6.5
    y = 1.28 + row*0.58
    rect(s,x,y,6.1,0.52,CARD)
    method_badge(s,x,y,method)
    box(s,x+1.02,y+0.05,2.6,0.24,path,size=10,bold=True,color=WHITE)
    box(s,x+1.02,y+0.28,2.6,0.2,desc,size=9,color=GRAY)

box(s,0.3,6.85,12.7,0.38,
    "All endpoints auto-documented at  http://localhost:8000/docs  (Swagger UI)",
    size=12,color=CYAN,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 5: Pydantic Schemas (Views) ─────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"Views — Pydantic Schemas (Input Validation)")

snippets = [
    ("StudentCreate\nschemas/student.py",
     "class StudentCreate(BaseModel):\n"
     "    student_id: str\n"
     "    first_name: str\n"
     "    last_name:  str\n"
     "    email:      Optional[str]\n"
     "    course:     str\n"
     "    year_level: int = 1"),
    ("ExamResultCreate\nschemas/exam_result.py",
     "class ExamResultCreate(BaseModel):\n"
     "    student_id:      str\n"
     "    exam_id:         str\n"
     "    correct_answers: int\n"
     "    total_score:     float\n"
     "    percentage:      Optional[float]\n"
     "    grade:           Optional[str]\n"
     "    grade_point:     Optional[float]\n"
     "    remarks:         Optional[str]"),
    ("AuthLogin\nschemas/auth.py",
     "class AuthLogin(BaseModel):\n"
     "    email:    EmailStr\n"
     "    password: str\n\n"
     "class AuthSignup(BaseModel):\n"
     "    email:    EmailStr\n"
     "    password: str"),
]

for i,(title,code) in enumerate(snippets):
    x = 0.3 + i*4.35
    rect(s,x,1.28,4.1,0.55,ACCENT)
    box(s,x+0.12,1.32,3.9,0.48,title,size=11,bold=True,color=WHITE)
    rect(s,x,1.83,4.1,4.5,CARD2)
    box(s,x+0.15,1.9,3.85,4.35,code,size=10,color=GREEN)

box(s,0.3,6.5,12.7,0.55,
    "Pydantic automatically validates types, required fields, and email format.\n"
    "FastAPI returns HTTP 422 Unprocessable Entity on invalid input.",
    size=11,color=GRAY,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 6: MSU Grading Scale ────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"MSU-Tawi-Tawi Grading Scale")

# grading table
grades = [
    ("96-100","1.0","1.0","Excellent"),
    ("92-95", "1.25","1.25","Excellent"),
    ("88-91", "1.5","1.5","Very Good"),
    ("84-87", "1.75","1.75","Very Good"),
    ("80-83", "2.0","2.0","Good"),
    ("76-79", "2.25","2.25","Good"),
    ("72-75", "2.5","2.5","Satisfactory"),
    ("68-71", "2.75","2.75","Satisfactory"),
    ("60-67", "3.0","3.0","Passing"),
    ("Below 60","5.0","5.0","Failed"),
]
cols_w = [1.8,1.2,1.5,1.8]
cols_x = [0.4,2.25,3.5,5.05]
headers_ = ["Percentage","Grade","Grade Point","Description"]
for j,(hh,cx) in enumerate(zip(headers_,cols_x)):
    rect(s,cx,1.28,cols_w[j],0.42,ACCENT)
    box(s,cx+0.08,1.32,cols_w[j]-0.1,0.35,hh,size=11,bold=True,color=WHITE,align=PP_ALIGN.CENTER)
for i,(pct,gr,gp,desc) in enumerate(grades):
    row_c = CARD if i%2==0 else CARD2
    fail  = gr=="5.0"
    for j,(val,cx) in enumerate(zip([pct,gr,gp,desc],cols_x)):
        rect(s,cx,1.72+i*0.48,cols_w[j],0.46,row_c)
        box(s,cx+0.08,1.78+i*0.48,cols_w[j]-0.1,0.36,val,
            size=10,color=RED if fail else WHITE,align=PP_ALIGN.CENTER)

# GPA formula
rect(s,7.2,1.28,5.8,2.2,CARD)
rect(s,7.2,1.28,5.8,0.08,CYAN)
box(s,7.35,1.38,5.5,0.4,"Weighted GPA Formula",size=13,bold=True,color=CYAN)
box(s,7.35,1.85,5.5,0.5,
    "GPA = S(Grade Point x Units) / S(Units)",
    size=13,bold=True,color=WHITE,align=PP_ALIGN.CENTER)
box(s,7.35,2.4,5.5,0.9,
    "Example:  Math(3u x 1.5) + English(3u x 2.0) + PE(2u x 1.25)\n"
    "= 4.5 + 6.0 + 2.5 = 13.0  /  8 units  =  GPA: 1.625",
    size=10,color=GRAY,italic=True)

# interpretation
rect(s,7.2,3.6,5.8,0.38,CARD)
box(s,7.35,3.65,5.5,0.3,"GPA Interpretation",size=12,bold=True,color=CYAN)
interps = [
    ("1.0 - 1.25","Excellent"),("1.26 - 1.75","Very Good"),
    ("1.76 - 2.25","Good"),("2.26 - 2.75","Satisfactory"),
    ("2.76 - 3.0","Passing"),("Above 3.0","Failed"),
]
for i,(rng,label) in enumerate(interps):
    col = i%2; row = i//2
    x2 = 7.2 + col*2.9; y2 = 4.05 + row*0.55
    rect(s,x2,y2,2.8,0.48,CARD2)
    box(s,x2+0.1,y2+0.06,1.3,0.36,rng,size=10,color=CYAN)
    box(s,x2+1.45,y2+0.06,1.2,0.36,label,size=10,bold=True,
        color=RED if label=="Failed" else WHITE)

box(s,0.3,6.85,12.7,0.38,
    "Grade and grade_point are auto-assigned on POST /results/ based on percentage",
    size=11,color=GRAY,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 7: Setup & Testing ───────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s)
header(s,"Setup, Run & Testing")

# setup steps
box(s,0.4,1.28,5.5,0.38,"Quick Setup",size=14,bold=True,color=CYAN)
steps = [
    ("1","git clone  https://github.com/kayting4000/EduScan.git"),
    ("2","cd EduScan/backend"),
    ("3","pip install -r requirements.txt"),
    ("4","Create .env  ->  SUPABASE_URL + SUPABASE_KEY"),
    ("5","python -m uvicorn main:app --reload"),
    ("6","Open  http://localhost:8000/docs"),
]
for i,(num,cmd) in enumerate(steps):
    y = 1.75+i*0.75
    rect(s,0.4,y,0.48,0.58,ACCENT)
    box(s,0.4,y+0.1,0.48,0.38,num,size=14,bold=True,color=WHITE,align=PP_ALIGN.CENTER)
    rect(s,0.93,y,5.5,0.58,CARD)
    box(s,1.05,y+0.12,5.3,0.36,cmd,size=10,color=WHITE)

# test script
box(s,7.0,1.28,6.0,0.38,"Test Script  (test_api.py)",size=14,bold=True,color=CYAN)
test_code = (
    "# Run while server is running:\n"
    "python test_api.py\n\n"
    "Tests:\n"
    "  [Health]    GET /\n"
    "  [Students]  POST / GET / PUT / DELETE\n"
    "  [Subjects]  POST / GET / PUT / DELETE\n"
    "  [Exams]     POST / GET / DELETE\n"
    "  [Results]   POST / GET / DELETE\n"
    "  [GPA]       GET /gpa/\n"
    "  [Dashboard] GET /dashboard/\n"
    "  [Cleanup]   removes all test data"
)
rect(s,7.0,1.75,6.1,4.5,CARD2)
box(s,7.15,1.85,5.85,4.3,test_code,size=10.5,color=GREEN)

box(s,0.3,6.85,12.7,0.38,
    "requirements.txt  |  README.md  |  test_api.py  all included in repository",
    size=11,color=GRAY,italic=True,align=PP_ALIGN.CENTER)

# ── SLIDE 8: Summary ───────────────────────────────────────
s = prs.slides.add_slide(BLANK); bg(s,DARK)
rect(s,0,3.05,13.33,0.07,ACCENT)
rect(s,0,3.12,13.33,0.04,CYAN)
box(s,1,0.4,11,0.9,"Milestone 2 — Delivered",size=36,bold=True,
    color=WHITE,align=PP_ALIGN.CENTER)

items = [
    ("Framework","FastAPI + Uvicorn","All services built with FastAPI"),
    ("MVC","models/ schemas/ controllers/","Strict separation of concerns"),
    ("Database","Supabase PostgreSQL","4 tables, FK relations, RLS"),
    ("CRUD","Students Subjects Exams Results","Full Create/Read/Update/Delete"),
    ("Validation","Pydantic v2","Input validation + error handling"),
    ("Grading","MSU-Tawi-Tawi Scale","1.0-5.0 + weighted GPA"),
    ("Docs","Swagger UI at /docs","Auto-generated, interactive"),
    ("Tests","test_api.py","Verifies all endpoints"),
    ("README","Setup + run instructions","requirements.txt included"),
]
xs2 = [0.4,4.6,8.8]
for i,(label,val,desc) in enumerate(items):
    col = i%3; row = i//3
    x = xs2[col]; y = 1.5+row*1.55
    rect(s,x,y,3.9,1.38,CARD)
    rect(s,x,y,3.9,0.07,ACCENT)
    box(s,x+0.15,y+0.12,3.6,0.38,label,size=11,bold=True,color=CYAN)
    box(s,x+0.15,y+0.48,3.6,0.35,val,size=13,bold=True,color=WHITE)
    box(s,x+0.15,y+0.85,3.6,0.38,desc,size=10,color=GRAY,italic=True)

box(s,1,6.1,11,0.45,"Thank you! Questions?",size=24,bold=True,
    color=WHITE,align=PP_ALIGN.CENTER)
box(s,1,6.6,11,0.38,"github.com/kayting4000/EduScan",size=13,
    color=CYAN,align=PP_ALIGN.CENTER,italic=True)

# ── save ──────────────────────────────────────────────────
out = r"d:\CCC151\test paper\EduScan_Milestone2_Final.pptx"
prs.save(out)
print("Saved: " + out)
