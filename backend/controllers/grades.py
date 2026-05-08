import httpx
from fastapi import APIRouter, Query
from typing import Optional
from database import rest_url, get_headers

router = APIRouter(prefix="/gpa", tags=["Grades"])


@router.get("/")
async def get_gpa(student_id: Optional[str] = Query(None)):
    params = {"select": "percentage"}
    if student_id:
        params["student_id"] = f"eq.{student_id}"
    async with httpx.AsyncClient() as client:
        res = await client.get(rest_url("exam_results"), headers=get_headers(), params=params)
    results = res.json()
    if not results:
        return {"gpa": 0.0, "average_percentage": 0.0}
    avg = sum(r["percentage"] or 0 for r in results) / len(results)
    gpa = round(max(1.0, min(4.0, avg / 100 * 3.0 + 1.0)), 2)
    return {"gpa": gpa, "average_percentage": round(avg, 2)}
