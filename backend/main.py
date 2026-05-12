from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controllers import (
    auth_router, students_router, subjects_router,
    exams_router, results_router, dashboard_router, grades_router,
    scanner_router,
)

app = FastAPI(
    title="EduScan API",
    description="Backend API for EduScan — Test Paper Scanner & Grade Management",
    version="1.0.0",
    contact={"name": "Habibun-najal K. Kayting", "email": "kayting4k@gmail.com"},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(students_router)
app.include_router(subjects_router)
app.include_router(exams_router)
app.include_router(results_router)
app.include_router(dashboard_router)
app.include_router(grades_router)
app.include_router(scanner_router)


@app.get("/", tags=["Health"])
def root():
    return {
        "app": "EduScan API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
    }
