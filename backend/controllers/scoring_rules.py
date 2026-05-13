"""
Scoring Rules controller — CRUD for scoring_rules table (Neon PostgreSQL).
"""
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from sqlalchemy.orm import Session

from database import get_db
from controllers.auth import get_current_user
from models.scoring_rule import ScoringRule
from models.user import User
from schemas import ScoringRuleCreate, ScoringRuleUpdate

router = APIRouter(prefix="/scoring-rules", tags=["Scoring Rules"])


def _serialize(sr: ScoringRule) -> dict:
    return {
        "id": str(sr.id),
        "user_id": str(sr.user_id),
        "exam_id": str(sr.exam_id),
        "section_name": sr.section_name,
        "item_start": sr.item_start,
        "item_end": sr.item_end,
        "points_per_item": sr.points_per_item,
        "created_at": sr.created_at.isoformat() if sr.created_at else None,
    }


@router.get("/")
def get_scoring_rules(
    exam_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    q = db.query(ScoringRule).filter(ScoringRule.user_id == current_user.id)
    if exam_id:
        q = q.filter(ScoringRule.exam_id == exam_id)
    q = q.order_by(ScoringRule.item_start.asc())
    return [_serialize(sr) for sr in q.all()]


@router.post("/")
def create_scoring_rule(
    body: ScoringRuleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    sr = ScoringRule(
        user_id=current_user.id,
        exam_id=body.exam_id,
        section_name=body.section_name,
        item_start=body.item_start,
        item_end=body.item_end,
        points_per_item=body.points_per_item,
    )
    db.add(sr)
    db.commit()
    db.refresh(sr)
    return _serialize(sr)


@router.put("/{rule_id}")
def update_scoring_rule(
    rule_id: str,
    body: ScoringRuleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    sr = db.query(ScoringRule).filter(
        ScoringRule.id == rule_id, ScoringRule.user_id == current_user.id
    ).first()
    if not sr:
        raise HTTPException(status_code=404, detail="ScoringRule not found")
    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(sr, key, value)
    db.commit()
    db.refresh(sr)
    return _serialize(sr)


@router.delete("/{rule_id}")
def delete_scoring_rule(
    rule_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    sr = db.query(ScoringRule).filter(
        ScoringRule.id == rule_id, ScoringRule.user_id == current_user.id
    ).first()
    if not sr:
        raise HTTPException(status_code=404, detail="ScoringRule not found")
    db.delete(sr)
    db.commit()
    return {"message": "ScoringRule deleted"}