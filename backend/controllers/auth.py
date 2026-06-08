"""
Auth controller — JWT-based authentication for Neon PostgreSQL.
Replaces the Supabase Auth REST API calls with local bcrypt + python-jose.
Now includes role-based access control (RBAC):
  - admin   : full access
  - teacher : manage students, subjects, exams, grades
  - student : read-only access to own data
"""
import os
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from dotenv import load_dotenv
import uuid

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


VALID_ROLES = {"admin", "teacher", "student"}


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def hash_password(password: str) -> str:
    return pwd_context.hash(password[:72])


def create_access_token(user_id: str, role: str = "admin") -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXPIRE_MINUTES)
    to_encode = {"sub": user_id, "role": role, "exp": expire}
    return jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> dict:
    """Returns payload dict from valid JWT. Raises HTTPException if invalid."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def get_current_user(
    token: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
):
    """
    Validate token payload and return a User instance.
    Defensive checks prevent invalid types (e.g. {} or str) from reaching SQLAlchemy.
    """
    # decode the JWT from the HTTPBearer credentials
    try:
        payload = jwt.decode(
            token.credentials,
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM],
        )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user_id = payload.get("sub") or payload.get("user_id") or payload.get("id")

    # Reject missing/invalid user id early
    if not user_id or isinstance(user_id, dict):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid authentication token",
        )

    # Normalize user_id to int or uuid.UUID before querying DB
    try:
        if isinstance(user_id, str):
            if "-" in user_id:
                user_id = uuid.UUID(user_id)
            else:
                user_id = int(user_id)
        elif isinstance(user_id, float):
            user_id = int(user_id)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user id in token",
        )

    # safe DB lookup
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


def require_role(*allowed_roles: str):
    """
    Dependency factory: returns a FastAPI dependency that asserts the
    authenticated user has one of the given roles.

    Usage:
        @router.get("/secret")
        def secret(user: User = Depends(require_role("admin", "teacher"))):
            ...
    """
    allowed = set(allowed_roles)

    def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Requires one of these roles: {', '.join(sorted(allowed))}",
            )
        return current_user

    return role_checker


# ─── Endpoints ──────────────────────────────────────────────────────────────


@router.post("/signup")
def signup(body: AuthSignup, db: Session = Depends(get_db)):
    try:
        role = body.role or "admin"
        if role not in VALID_ROLES:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid role '{role}'. Must be one of: {', '.join(sorted(VALID_ROLES))}",
            )

        existing = db.query(User).filter(User.email == body.email).first()
        if existing:
            raise HTTPException(status_code=409, detail="Email already registered")
        user = User(
            email=body.email,
            password_hash=hash_password(body.password),
            role=role,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        token = create_access_token(str(user.id), role=user.role)
        return {
            "access_token": token,
            "user": {
                "id": str(user.id),
                "email": user.email,
                "role": user.role,
            },
        }
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"SIGNUP ERROR: {type(e).__name__}: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Signup failed: {type(e).__name__}: {str(e)[:200]}")


@router.post("/login")
def login(body: AuthLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(str(user.id), role=user.role)
    return {
        "access_token": token,
        "user": {
            "id": str(user.id),
            "email": user.email,
            "role": user.role,
        },
    }