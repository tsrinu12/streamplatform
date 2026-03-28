from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import tempfile
import shutil
import os
import numpy as np
from loguru import logger

from .inference import VJEPAEmbeddingService
from ..config.settings import settings

app = FastAPI(title="V-JEPA Embedding Service")
vjepa_service = None

@app.on_event("startup")
async def startup_event():
    global vjepa_service
    vjepa_service = VJEPAEmbeddingService(
        model_name=settings.vjepa_model_name,
        device=settings.device
    )

class EmbeddingResponse(BaseModel):
    video_id: str
    embeddings: List[List[float]]
    timestamps: List[float]

@app.post("/embed-video", response_model=EmbeddingResponse)
async def embed_video(file: UploadFile = File(...), fps: int = 2):
    if not vjepa_service:
        raise HTTPException(status_code=503, detail="Service initializing")
    
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        shutil.copyfileobj(file.file, tmp)
        temp_path = tmp.name
    
    try:
        embeddings, timestamps = vjepa_service.video_to_embeddings(temp_path, fps=fps)
        return EmbeddingResponse(
            video_id=file.filename,
            embeddings=embeddings.tolist(),
            timestamps=timestamps
        )
    finally:
        os.remove(temp_path)

@app.get("/health")
async def health():
    return {"status": "healthy", "model": settings.vjepa_model_name}
