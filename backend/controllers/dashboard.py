import asyncio
import httpx
from fastapi import APIRouter
from database import rest_url, get_headers

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/")
async def get_dashboard_stats():
    async with httpx.AsyncClient() as client:
        h = get_headers()
        h["Prefer"] = "count=exact"
        students, subjects, exams, results = await asyncio.gather(
            client.get(rest_url("students"),     headers=h, params={"select": "id"}),
            client.get(rest_url("subjects"),     headers=h, params={"select": "id"}),
            client.get(rest_url("exams"),        headers=h, params={"select": "id"}),
            client.get(rest_url("exam_results"), headers=h, params={"select": "id"}),
        )
    return {
        "total_students": len(students.json()),
        "total_subjects": len(subjects.json()),
        "total_exams":    len(exams.json()),
        "total_results":  len(results.json()),
    }
