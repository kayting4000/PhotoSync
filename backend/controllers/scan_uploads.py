"""
Scan Uploads controller — handles image upload, compression, and linking to student/exam.
Supports local file storage and base64 inline storage for cloud (Render free tier).
"""
import os
import uuid
import base64
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from PIL import Image  # type: ignore
import io

from database import get_db
from controllers.auth import get_current_user
from models.user import User
from models.exam_result import ExamResult

router = APIRouter(prefix="/scan-uploads", tags=["Scan Uploads"])

# Render.com free tier uses ephemeral filesystem — use inline base64 storage
# Local dev can set USE_LOCAL_STORAGE=true for file-based storage
USE_LOCAL_STORAGE = os.getenv("USE_LOCAL_STORAGE", "false").lower() == "true"
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
if USE_LOCAL_STORAGE:
    os.makedirs(UPLOAD_DIR, exist_ok=True)

MAX_IMAGE_SIZE = 1024
QUALITY = 75


def _compress_image(file_bytes: bytes) -> bytes:
    """Compress and resize image to reduce file size."""
    img = Image.open(io.BytesIO(file_bytes))
    if img.mode in ("RGBA", "P"):
        img = img.convert("RGB")
    if img.width > MAX_IMAGE_SIZE or img.height > MAX_IMAGE_SIZE:
        ratio = min(MAX_IMAGE_SIZE / img.width, MAX_IMAGE_SIZE / img.height)
        new_w = int(img.width * ratio)
        new_h = int(img.height * ratio)
        img = img.resize((new_w, new_h), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=QUALITY, optimize=True)
    return buf.getvalue()


@router.post("/upload")
async def upload_scan(
    student_id: str = Form(...),
    exam_id: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Upload a scanned test paper image, compress it, and link to an exam result."""
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are allowed")

    raw_bytes = await file.read()
    compressed = _compress_image(raw_bytes)

    # Store as base64 inline (cloud-compatible) or file path (local dev)
    if USE_LOCAL_STORAGE:
        filename = f"{uuid.uuid4()}.jpg"
        filepath = os.path.join(UPLOAD_DIR, filename)
        with open(filepath, "wb") as f:
            f.write(compressed)
        file_url = f"/uploads/{filename}"
    else:
        file_url = f"data:image/jpeg;base64,{base64.b64encode(compressed).decode()}"

    # Upsert exam result record
    existing = db.query(ExamResult).filter(
        ExamResult.user_id == current_user.id,
        ExamResult.student_id == student_id,
        ExamResult.exam_id == exam_id,
    ).first()

    if existing:
        existing.scanned_image_url = file_url
        db.commit()
        db.refresh(existing)
        result_id = str(existing.id)
    else:
        result = ExamResult(
            user_id=current_user.id,
            student_id=student_id,
            exam_id=exam_id,
            correct_answers=0,
            total_score=0.0,
            scanned_image_url=file_url,
        )
        db.add(result)
        db.commit()
        db.refresh(result)
        result_id = str(result.id)

    return {
        "success": True,
        "file_url": file_url[:80] + "..." if not USE_LOCAL_STORAGE else file_url,
        "result_id": result_id,
        "size_bytes": len(compressed),
        "original_size_bytes": len(raw_bytes),
        "compression_ratio": f"{len(compressed) / len(raw_bytes) * 100:.1f}%",
    }


@router.get("/results/{student_id}/{exam_id}")
def get_scanned_result(
    student_id: str,
    exam_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get the scanned image URL for a student+exam combination."""
    result = db.query(ExamResult).filter(
        ExamResult.user_id == current_user.id,
        ExamResult.student_id == student_id,
        ExamResult.exam_id == exam_id,
    ).first()

    if not result or not result.scanned_image_url:
        return {"scanned_image_url": None, "has_scan": False}

    return {
        "scanned_image_url": result.scanned_image_url,
        "has_scan": True,
    }