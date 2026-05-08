import httpx
from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from database import rest_url, get_headers
from schemas import ExamResultCreate
from models.exam_result import TABLE

router = APIRouter(prefix="/results", tags=["Results"])


def _assign_grade(percentage: float) -> str:
    if percentage >= 90: return "A+"
    if percentage >= 85: return "A"
    if percentage >= 80: return "B+"
    if percentage >= 75: return "B"
    if percentage >= 70: return "C+"
    if percentage >= 65: return "C"
    if percentage >= 60: return "D"
    return "F"


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
    if data.get("percentage") and not data.get("grade"):
        data["grade"] = _assign_grade(data["percentage"])
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
