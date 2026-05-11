import httpx
from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from database import rest_url, get_headers
from schemas import ExamCreate, ExamUpdate
from models.exam import TABLE

router = APIRouter(prefix="/exams", tags=["Exams"])


@router.get("/")
async def get_exams(subject_id: Optional[str] = Query(None)):
    params = {"select": "*", "order": "created_at.desc"}
    if subject_id:
        params["subject_id"] = f"eq.{subject_id}"
    async with httpx.AsyncClient() as client:
        res = await client.get(rest_url(TABLE), headers=get_headers(), params=params)
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@router.post("/")
async def create_exam(body: ExamCreate):
    async with httpx.AsyncClient() as client:
        res = await client.post(rest_url(TABLE), headers=get_headers(), json=body.model_dump())
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@router.put("/{exam_id}")
async def update_exam(exam_id: str, body: ExamUpdate):
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    async with httpx.AsyncClient() as client:
        res = await client.patch(rest_url(TABLE), headers=get_headers(),
                                 json=data, params={"id": f"eq.{exam_id}"})
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@router.delete("/{exam_id}")
async def delete_exam(exam_id: str):
    async with httpx.AsyncClient() as client:
        res = await client.delete(rest_url(TABLE), headers=get_headers(),
                                  params={"id": f"eq.{exam_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Exam deleted"}
