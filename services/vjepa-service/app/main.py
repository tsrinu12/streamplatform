from fastapi import FastAPI, UploadFile, File, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional
import tempfile
import shutil
import os
import numpy as np
from loguru import logger

from .inference import VJEPAEmbeddingService
from .middleware.auth import verify_jwt

app = FastAPI(title="V-JEPA Embedding Service")
vjepa_service = None

@app.on_event("startup")
async def startup_event():
    global vjepa_service
    # Production: Load model from S3 or local path
    model_path = os.getenv("MODEL_PATH", "models/vjepa_main.pth")
    vjepa_service = VJEPAEmbeddingService(
        model_path=model_path,
        device="cuda" if os.getenv("ENABLE_GPU") == "true" else "cpu"
    )
    logger.info("V-JEPA Service initialized successfully")

class EmbeddingResponse(BaseModel):
    video_id: str
    embeddings: List[List[float]]
    timestamps: List[float]

@app.post("/embed-video", response_model=EmbeddingResponse)
async def embed_video(
    file: UploadFile = File(...), 
    fps: int = 2,
    user: dict = Depends(verify_jwt) # Enterprise Security
):
    if not vjepa_service:
        raise HTTPException(status_code=503, detail="Service initializing")
    
    logger.info(f"Processing video for user: {user.get('sub')}")
    
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        shutil.copyfileobj(file.file, tmp)
        tmp_path = tmp.name

    try:
        # V-JEPA Algorithm logic
        embeddings, timestamps = vjepa_service.process_video(tmp_path, fps=fps)
        return EmbeddingResponse(
            video_id=file.filename,
            embeddings=embeddings.tolist(),
            timestamps=timestamps
        )
    except Exception as e:
        logger.error(f"Error processing video: {str(e)}")
        raise HTTPException(status_code=500, detail="Inference failed")
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "gpu_available": os.getenv("ENABLE_GPU") == "true"}
