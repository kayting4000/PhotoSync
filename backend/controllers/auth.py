"""
Auth controller — JWT-based authentication for Neon PostgreSQL.
Replaces the Supabase Auth REST API calls with local bcrypt + python-jose.
"""
import os
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from database import get_db
from models.user import User
from schemas import AuthLogin, AuthSignup

load_dotenv()

router = APIRouter(prefix="/auth", tags=["Auth"])

JWT_SECRET = os.getenv("JWT_SECRET", "change-me-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXPIRE_MINUTES)
    to_encode = {"sub": user_id, "exp": expire}
    return jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> str:
    """Returns user_id from valid JWT. Raises HTTPException if invalid."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token: missing sub")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """FastAPI dependency: returns the authenticated User from JWT."""
    user_id = decode_token(credentials.credentials)
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user


@router.post("/signup")
def signup(body: AuthSignup, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == body.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email already registered")
    user = User(
        email=body.email,
        password_hash=hash_password(body.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    token = create_access_token(str(user.id))
    return {
        "access_token": token,
        "user": {"id": str(user.id), "email": user.email},
    }


@router.post("/login")
def login(body: AuthLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(str(user.id))
    return {
        "access_token": token,
        "user": {"id": str(user.id), "email": user.email},
    }