from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import tempfile
import shutil
import os
from loguru import logger
from .inference import ComputerVisionService

app = FastAPI(title=\"Computer Vision Service\")
cv_service = None

# Temporary mock settings until config is added
class Settings:
    model_name: str = \"yolov8n.pt\"
    device: str = \"cpu\"
settings = Settings()

@app.on_event(\"startup\")
async def startup_event():
    global cv_service
    cv_service = ComputerVisionService(
        model_name=settings.model_name,
        device=settings.device
    )

class DetectionResult(BaseModel):
    timestamp: float
    detections: List[dict]

class CVResponse(BaseModel):
    video_id: str
    results: List[DetectionResult]

@app.post(\"/process-video\", response_model=CVResponse)
async def process_video(file: UploadFile = File(...), fps: int = 1):
    if not cv_service:
        raise HTTPException(status_code=503, detail=\"Service initializing\")
        
    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=\".mp4\") as temp_file:
            shutil.copyfileobj(file.file, temp_file)
            temp_path = temp_file.name
            
        results = cv_service.process_video(temp_path, fps=fps)
        return CVResponse(
            video_id=file.filename,
            results=[DetectionResult(**r) for r in results]
        )
    except Exception as e:
        logger.error(f\"Error processing video: {str(e)}\")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_path and os.path.exists(temp_path):
            os.remove(temp_path)

@app.get(\"/health\")
async def health():
    return {\"status\": \"healthy\", \"model\": settings.model_name}
