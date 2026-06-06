from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from controllers.subjects import router as subjects_router
from controllers.students import router as students_router
from controllers.exams import router as exams_router
from controllers.results import router as results_router

app = FastAPI(title="PhotoSync API", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(subjects_router)
app.include_router(students_router)
app.include_router(exams_router)
app.include_router(results_router)