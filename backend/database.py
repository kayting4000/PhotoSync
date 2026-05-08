import httpx
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation",
}

def get_headers(token: str = None):
    h = HEADERS.copy()
    if token:
        h["Authorization"] = f"Bearer {token}"
    return h

def rest_url(table: str) -> str:
    return f"{SUPABASE_URL}/rest/v1/{table}"

def auth_url(path: str) -> str:
    return f"{SUPABASE_URL}/auth/v1/{path}"
