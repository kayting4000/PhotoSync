import httpx
import os
import hashlib
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

ROBOFLOW_API_KEY = os.getenv("ROBOFLOW_API_KEY")
ROBOFLOW_WORKSPACE = os.getenv("ROBOFLOW_WORKSPACE")
ROBOFLOW_WORKFLOW_ID = os.getenv("ROBOFLOW_WORKFLOW_ID")

# Reuse HTTP client across requests (connection pooling)
_client: httpx.AsyncClient | None = None


async def get_client() -> httpx.AsyncClient:
    global _client
    if _client is None or _client.is_closed:
        _client = httpx.AsyncClient(
            timeout=httpx.Timeout(60.0, connect=10.0),
            limits=httpx.Limits(max_keepalive_connections=5, max_connections=10),
            headers={"Content-Type": "application/json"},
        )
    return _client


router = APIRouter(prefix="/scanner", tags=["Scanner"])


class ScanRequest(BaseModel):
    image_base64: str


def _image_hash(image_base64: str) -> str:
    """Create a hash of the first 1KB of image data for caching similar scans."""
    return hashlib.md5(image_base64[:1024].encode()).hexdigest()


# In-memory cache for scan results (limited to 50 entries)
_scan_cache: dict[str, dict] = {}
_MAX_CACHE_SIZE = 50


@router.post("/scan")
async def scan_image(body: ScanRequest):
    if not all([ROBOFLOW_API_KEY, ROBOFLOW_WORKSPACE, ROBOFLOW_WORKFLOW_ID]):
        raise HTTPException(status_code=500, detail="Roboflow credentials not configured")

    # Check in-memory cache first
    cache_key = _image_hash(body.image_base64)
    if cache_key in _scan_cache:
        return _scan_cache[cache_key]

    url = f"https://serverless.roboflow.com/{ROBOFLOW_WORKSPACE}/workflows/{ROBOFLOW_WORKFLOW_ID}"

    payload = {
        "api_key": ROBOFLOW_API_KEY,
        "inputs": {
            "image": {
                "type": "base64",
                "value": body.image_base64,
            }
        },
        "use_cache": True,
    }

    try:
        client = await get_client()
        res = await client.post(url, json=payload)

        if res.status_code != 200:
            raise HTTPException(status_code=res.status_code, detail=res.text)

        data = res.json()
        count = 0
        visualization_url = None

        try:
            if isinstance(data, list) and data:
                result = data[0]
                if result.get("predictions", {}).get("predictions"):
                    count = len(result["predictions"]["predictions"])
                if result.get("visualization"):
                    visualization_url = result["visualization"].get("url")
            elif isinstance(data, dict):
                outputs = data.get("outputs", data)
                if outputs.get("count") is not None:
                    count = int(outputs["count"])
                if outputs.get("visualization"):
                    visualization_url = outputs["visualization"].get("url") or str(outputs["visualization"])
        except Exception:
            pass

        result = {"count": count, "visualization_url": visualization_url}

        # Store in cache (evict oldest if full)
        if len(_scan_cache) >= _MAX_CACHE_SIZE:
            _scan_cache.pop(next(iter(_scan_cache)))
        _scan_cache[cache_key] = result

        return result
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Scanner API request timed out")
    except httpx.ConnectError:
        raise HTTPException(status_code=502, detail="Could not connect to scanner API")
