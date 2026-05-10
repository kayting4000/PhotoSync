import httpx
from fastapi import APIRouter, Query, HTTPException
from typing import Optional
from database import rest_url, get_headers

router = APIRouter(prefix="/gpa", tags=["Grades"])

# MSU-Tawi-Tawi: GPA = sum(units × grade_point) / sum(units)
# grade 5.0 (Failed) is still included in computation
# INC / dropped subjects are excluded (no grade_point stored)

@router.get("/")
async def get_gpa(student_id: Optional[str] = Query(None)):
    # fetch results joined with exam → subject units
    params = {
        "select": "grade_point,percentage,exam_id,exams(subject_id,subjects(units))",
        "order": "created_at.desc",
    }
    if student_id:
        params["student_id"] = f"eq.{student_id}"

    async with httpx.AsyncClient() as client:
        res = await client.get(rest_url("exam_results"), headers=get_headers(), params=params)

    if res.status_code != 200:
        raise HTTPException(status_code=res.status_code, detail=res.text)

    results = res.json()
    if not results:
        return {"gpa": None, "total_units": 0, "subjects_counted": 0}

    weighted_sum = 0.0
    total_units  = 0

    for r in results:
        gp = r.get("grade_point")
        if gp is None:
            continue
        try:
            units = r["exams"]["subjects"]["units"]
        except (TypeError, KeyError):
            units = 3   # fallback default

        weighted_sum += gp * units
        total_units  += units

    if total_units == 0:
        return {"gpa": None, "total_units": 0, "subjects_counted": len(results)}

    gpa = round(weighted_sum / total_units, 4)
    return {
        "gpa": gpa,
        "total_units": total_units,
        "subjects_counted": len(results),
        "interpretation": _interpret(gpa),
    }


def _interpret(gpa: float) -> str:
    if gpa <= 1.25: return "Excellent"
    if gpa <= 1.75: return "Very Good"
    if gpa <= 2.25: return "Good"
    if gpa <= 2.75: return "Satisfactory"
    if gpa <= 3.0:  return "Passing"
    return "Failed"
