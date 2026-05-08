import httpx
from fastapi import APIRouter, HTTPException
from database import rest_url, get_headers
from schemas import SubjectCreate, SubjectUpdate
from models.subject import TABLE

router = APIRouter(prefix="/subjects", tags=["Subjects"])


@router.get("/")
async def get_subjects():
    async with httpx.AsyncClient() as client:
        res = await client.get(rest_url(TABLE), headers=get_headers(),
                               params={"select": "*", "order": "created_at.desc"})
    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()


@router.post("/")
async def create_subject(body: SubjectCreate):
    async with httpx.AsyncClient() as client:
        res = await client.post(rest_url(TABLE), headers=get_headers(), json=body.model_dump())
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@router.put("/{subject_id}")
async def update_subject(subject_id: str, body: SubjectUpdate):
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    async with httpx.AsyncClient() as client:
        res = await client.patch(rest_url(TABLE), headers=get_headers(),
                                 json=data, params={"id": f"eq.{subject_id}"})
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return res.json()[0]


@router.delete("/{subject_id}")
async def delete_subject(subject_id: str):
    async with httpx.AsyncClient() as client:
        res = await client.delete(rest_url(TABLE), headers=get_headers(),
                                  params={"id": f"eq.{subject_id}"})
    if res.status_code not in (200, 204):
        raise HTTPException(status_code=res.status_code, detail=res.text)
    return {"message": "Subject deleted"}
