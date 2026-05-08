import httpx
from fastapi import APIRouter, HTTPException
from database import auth_url, SUPABASE_KEY
from schemas import AuthLogin, AuthSignup

router = APIRouter(prefix="/auth", tags=["Auth"])

_AUTH_HEADERS = {"apikey": SUPABASE_KEY, "Content-Type": "application/json"}


@router.post("/signup")
async def signup(body: AuthSignup):
    async with httpx.AsyncClient() as client:
        res = await client.post(
            auth_url("signup"),
            json={"email": body.email, "password": body.password},
            headers=_AUTH_HEADERS,
        )
    if res.status_code not in (200, 201):
        raise HTTPException(status_code=res.status_code, detail=res.json())
    return res.json()


@router.post("/login")
async def login(body: AuthLogin):
    async with httpx.AsyncClient() as client:
        res = await client.post(
            auth_url("token?grant_type=password"),
            json={"email": body.email, "password": body.password},
            headers=_AUTH_HEADERS,
        )
    if res.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    data = res.json()
    return {"access_token": data.get("access_token"), "user": data.get("user")}
