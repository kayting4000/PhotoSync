from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models.gpa_config import GpaConfig
from schemas.gpa_config import GpaConfigUpdate
from controllers.auth import get_current_user

router = APIRouter(prefix="/gpa-config", tags=["GPA Config"])


@router.get("/")
def get_gpa_config(db: Session = Depends(get_db), user=Depends(get_current_user)):
    config = db.query(GpaConfig).filter(GpaConfig.user_id == user.id).first()
    if not config:
        return {"prelim_pct": 33, "midterm_pct": 33, "finals_pct": 34}
    return config


@router.put("/")
def update_gpa_config(data: GpaConfigUpdate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    config = db.query(GpaConfig).filter(GpaConfig.user_id == user.id).first()
    if config:
        config.prelim_pct = data.prelim_pct
        config.midterm_pct = data.midterm_pct
        config.finals_pct = data.finals_pct
    else:
        config = GpaConfig(
            user_id=user.id,
            prelim_pct=data.prelim_pct,
            midterm_pct=data.midterm_pct,
            finals_pct=data.finals_pct,
        )
        db.add(config)
    db.commit()
    db.refresh(config)
    return config
