from fastapi import FastAPI, UploadFile, File, HTTPException, Query
from fastapi.responses import JSONResponse
import whisper
import torch
import os
import tempfile
import shutil
from loguru import logger
from typing import List, Optional
from pydantic import BaseModel

app = FastAPI(title="NLP & Multimodal Service", version="1.0.0")

# Global model variable for lazy loading
model = None

@app.on_event("startup")
async def startup_event():
    """Initialize Whisper model on startup"""
    global model
    try:
        device = "cuda" if torch.cuda.is_available() else "cpu"
        logger.info(f"Initializing Whisper model on {device}...")
        model = whisper.load_model("base", device=device)
        logger.info("Whisper model loaded successfully.")
    except Exception as e:
        logger.error(f"Failed to load Whisper model: {str(e)}")

class TranscriptionResult(BaseModel):
    text: str
    language: str
    segments: List[dict]

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "nlp-service",
        "model_loaded": model is not None,
        "device": "cuda" if torch.cuda.is_available() else "cpu"
    }

@app.post("/transcribe", response_model=TranscriptionResult)
async def transcribe_audio(
    file: UploadFile = File(...),
    task: str = Query("transcribe", enum=["transcribe", "translate"])
):
    """Transcribe or translate audio file using Whisper"""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not initialized")
    
    temp_path = None
    try:
        # Create temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1]) as tmp:
            shutil.copyfileobj(file.file, tmp)
            temp_path = tmp.name
        
        # Run inference
        result = model.transcribe(temp_path, task=task)
        
        return TranscriptionResult(
            text=result["text"],
            language=result["language"],
            segments=result["segments"]
        )
        
    except Exception as e:
        logger.error(f"Transcription error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    
    finally:
        # Cleanup
        if temp_path and os.path.exists(temp_path):
            os.remove(temp_path)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
