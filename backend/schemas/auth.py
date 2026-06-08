from typing import Optional
from pydantic import BaseModel, EmailStr


class AuthLogin(BaseModel):
    email: EmailStr
    password: str

    model_config = {
        "json_schema_extra": {
            "examples": [
                {"email": "juan.delacruz@example.com", "password": "SecurePass123"}
            ]
        }
    }


class AuthSignup(BaseModel):
    email: EmailStr
    password: str
    role: Optional[str] = 'admin'  # 'admin', 'teacher', or 'student'

    model_config = {
        "json_schema_extra": {
            "examples": [
                {"email": "juan.delacruz@example.com", "password": "SecurePass123"}
            ]
        }
    }


class UserResponse(BaseModel):
    id: str
    email: str
    role: str
    is_active: bool