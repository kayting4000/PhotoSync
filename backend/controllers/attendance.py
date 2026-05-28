from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import and_
from database import get_db
from models.attendance import Attendance
from schemas.attendance import AttendanceCreate, AttendanceUpdate
from controllers.auth import get_current_user
import uuid

router = APIRouter(prefix="/attendance", tags=["Attendance"])


@router.get("/student/{student_id}/subject/{subject_id}")
def get_attendance(student_id: str, subject_id: str, year: int = None, month: int = None,
                   db: Session = Depends(get_db), user=Depends(get_current_user)):
    filters = [
        Attendance.user_id == user.id,
        Attendance.student_id == uuid.UUID(student_id),
        Attendance.subject_id == uuid.UUID(subject_id),
    ]
    if year:
        filters.append(Attendance.year == year)
    if month:
        filters.append(Attendance.month == month)
    records = db.query(Attendance).filter(and_(*filters)).all()
    return records


@router.get("/student/{student_id}/subject/{subject_id}/summary")
def get_attendance_summary(student_id: str, subject_id: str, year: int = None, month: int = None,
                            db: Session = Depends(get_db), user=Depends(get_current_user)):
    filters = [
        Attendance.user_id == user.id,
        Attendance.student_id == uuid.UUID(student_id),
        Attendance.subject_id == uuid.UUID(subject_id),
    ]
    if year:
        filters.append(Attendance.year == year)
    if month:
        filters.append(Attendance.month == month)
    records = db.query(Attendance).filter(and_(*filters)).all()
    return {
        "present": sum(1 for r in records if r.status == "present"),
        "late": sum(1 for r in records if r.status == "late"),
        "absent": sum(1 for r in records if r.status == "absent"),
    }


@router.post("/")
def upsert_attendance(data: AttendanceCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    existing = db.query(Attendance).filter(
        Attendance.user_id == user.id,
        Attendance.student_id == uuid.UUID(data.student_id),
        Attendance.subject_id == uuid.UUID(data.subject_id),
        Attendance.year == data.year,
        Attendance.month == data.month,
        Attendance.day == data.day,
    ).first()
    if existing:
        existing.status = data.status
        db.commit()
        db.refresh(existing)
        return existing
    record = Attendance(
        user_id=user.id,
        student_id=uuid.UUID(data.student_id),
        subject_id=uuid.UUID(data.subject_id),
        year=data.year,
        month=data.month,
        day=data.day,
        status=data.status,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.delete("/{attendance_id}")
def delete_attendance(attendance_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    record = db.query(Attendance).filter(
        Attendance.id == uuid.UUID(attendance_id),
        Attendance.user_id == user.id,
    ).first()
    if not record:
        raise HTTPException(status_code=404, detail="Not found")
    db.delete(record)
    db.commit()
    return {"deleted": True}
