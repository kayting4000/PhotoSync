import httpx
import os
import json
import hashlib
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("scanner")

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
    page_number: int = 1
    total_pages: int = 1


def _image_hash(image_base64: str) -> str:
    """Create a hash of the first 1KB of image data for caching similar scans."""
    return hashlib.md5(image_base64[:1024].encode()).hexdigest()


# In-memory cache for scan results (limited to 50 entries)
_scan_cache: dict[str, dict] = {}
_MAX_CACHE_SIZE = 50


def _recursive_search(obj, target_key: str, depth=0):
    """Recursively search for a key in nested dict/list structures."""
    if depth > 10:
        return None
    if isinstance(obj, dict):
        # Direct match
        if target_key in obj:
            return obj[target_key]
        # Recurse into values
        for v in obj.values():
            result = _recursive_search(v, target_key, depth + 1)
            if result is not None:
                return result
        # Also check nested under "outputs" if present
        if "outputs" in obj and isinstance(obj["outputs"], list):
            for item in obj["outputs"]:
                result = _recursive_search(item, target_key, depth + 1)
                if result is not None:
                    return result
    elif isinstance(obj, list):
        for item in obj:
            result = _recursive_search(item, target_key, depth + 1)
            if result is not None:
                return result
    return None


def _extract_count(data: dict) -> int:
    """Extract count of detected items from Roboflow workflow response."""
    # Log the raw response structure (first 2KB)
    raw_preview = json.dumps(data, indent=2)[:2000]
    logger.info(f"Raw response preview:\n{raw_preview}")

    # Strategy 1: Look for "count_objects" (our workflow uses this key)
    count_val = _recursive_search(data, "count_objects")
    if count_val is not None and isinstance(count_val, (int, float)):
        logger.info(f"Found count_objects: {count_val}")
        return int(count_val)

    # Strategy 2: Look for "count" anywhere in the response
    count_val = _recursive_search(data, "count")
    if count_val is not None and isinstance(count_val, (int, float)):
        logger.info(f"Found count via recursive search: {count_val}")
        return int(count_val)

    # Strategy 3: Look for predictions array
    predictions = _recursive_search(data, "predictions")
    if isinstance(predictions, list) and len(predictions) > 0:
        logger.info(f"Found predictions list with {len(predictions)} items")
        return len(predictions)
    if isinstance(predictions, dict):
        preds_list = predictions.get("predictions", [])
        if isinstance(preds_list, list) and len(preds_list) > 0:
            logger.info(f"Found nested predictions with {len(preds_list)} items")
            return len(preds_list)

    # Strategy 4: Look for any numeric score/confidence that indicates detection
    scores = _recursive_search(data, "confidence")
    if isinstance(scores, list) and len(scores) > 0:
        logger.info(f"Found confidence list with {len(scores)} entries")
        return len(scores)
    if isinstance(scores, (int, float)) and scores > 0:
        logger.info(f"Found single confidence: {scores}")
        return 1

    # Strategy 5: Look for "detections" key
    detections = _recursive_search(data, "detections")
    if isinstance(detections, list) and len(detections) > 0:
        logger.info(f"Found detections list with {len(detections)} items")
        return len(detections)

    # Strategy 6: Count any prediction-like objects (objects with confidence + class)
    def count_predictions(obj, depth=0):
        if depth > 10:
            return 0
        total = 0
        if isinstance(obj, dict):
            if "confidence" in obj and "class" in obj:
                return 1
            if "x" in obj and "y" in obj and "width" in obj and "height" in obj:
                return 1
            for v in obj.values():
                total += count_predictions(v, depth + 1)
        elif isinstance(obj, list):
            for item in obj:
                total += count_predictions(item, depth + 1)
        return total

    pred_count = count_predictions(data)
    if pred_count > 0:
        logger.info(f"Found {pred_count} prediction-like objects")
        return pred_count

    return 0


def _extract_visualization(data: dict) -> str | None:
    """Extract visualization URL from Roboflow workflow response."""
    viz = _recursive_search(data, "visualization")
    if viz:
        if isinstance(viz, dict):
            return viz.get("url") or str(viz.get("value", ""))
        return str(viz)
    return None


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
        count = _extract_count(data)
        visualization_url = _extract_visualization(data)

        logger.info(f"Final result - count: {count}, viz: {bool(visualization_url)}")

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