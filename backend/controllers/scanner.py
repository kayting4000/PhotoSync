import httpx
import os
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

ROBOFLOW_API_KEY = os.getenv("ROBOFLOW_API_KEY")
ROBOFLOW_WORKSPACE = os.getenv("ROBOFLOW_WORKSPACE")
ROBOFLOW_WORKFLOW_ID = os.getenv("ROBOFLOW_WORKFLOW_ID")

router = APIRouter(prefix="/scanner", tags=["Scanner"])


class ScanRequest(BaseModel):
    image_base64: str


@router.post("/scan")
async def scan_image(body: ScanRequest):
    if not all([ROBOFLOW_API_KEY, ROBOFLOW_WORKSPACE, ROBOFLOW_WORKFLOW_ID]):
        raise HTTPException(status_code=500, detail="Roboflow credentials not configured")

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

    async with httpx.AsyncClient(timeout=60.0) as client:
        res = await client.post(url, json=payload, headers={"Content-Type": "application/json"})

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

    return {
        "count": count,
        "visualization_url": visualization_url,
    }
