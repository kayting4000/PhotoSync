import httpx
from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from database import rest_url, get_headers
from schemas import ExamResultCreate
from models.exam_result import TABLE

router = APIRouter(prefix="/results", tags=["Results"])


# MSU Grading Scale
def _assign_grade(percentage: float) -> tuple[str, float, str]:
    """Returns (grade_letter, grade_point, remarks) using MSU scale."""
    if percentage >= 96: return "1.0", 1.0, "Passed"
    if percentage >= 92: return "1.25", 1.25, "Passed"
    if percentage >= 88: return "1.5", 1.5, "Passed"
    if percentage >= 84: return "1.75", 1.75, "Passed"
    if percentage >= 80: return "2.0", 2.0, "Passed"
    if percentage >= 76: return "2.25", 2.25, "Passed"
    if percentage >= 72: return "2.5", 2.5, "Passed"
    if percentage >= 68: return "2.75", 2.75, "Passed"
    if percentage >= 60: return "3.0", 3.0, "Passed"
    return "5.0", 5.0, "Failed"


@router.get("/")
async def get_results(student_id: Optional[str] = Query(None),
                      exam_id: Optional[str] = Query(None)):
    params = {"select": "*", "order": "created_at.desc"}
    if student_id:
        params["student_id"] = f"eq.{student_id}"
    if exam_id:
        params["exam_id"] = f"eq.{exam_id}"
    async with httpx.AsyncClient() as client:
        res = await client.get(rest_url(TABLE), headers=get_headers(), params=params)
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@router.post("/")
async def create_result(body: ExamResultCreate):
    data = body.model_dump()
    if data.get("percentage") is not None and not data.get("grade"):
        grade, gp, remarks = _assign_grade(data["percentage"])
        data["grade"] = grade
        data["grade_point"] = gp
        data.setdefault("remarks", remarks)
    async with httpx.AsyncClient() as client:
        res = await client.post(rest_url(TABLE), headers=get_headers(), json=data)
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@router.delete("/{result_id}")
async def delete_result(result_id: str):
    async with httpx.AsyncClient() as client:
        res = await client.delete(rest_url(TABLE), headers=get_headers(),
                                  params={"id": f"eq.{result_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Result deleted"}
