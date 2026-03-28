import os
from fastapi import FastAPI, HTTPException, UploadFile, File
from loguru import logger
import whisper
import torch

app = FastAPI(title="NLP Service")

# Load model lazily
model = None

@app.on_event("startup")
async def startup_event():
    global model
    logger.info("Initializing Whisper model...")
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model = whisper.load_model("base", device=device)
    logger.info(f"Model loaded on {device}")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/transcribe")
async def transcribe_audio(file: UploadFile = File(...)):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not initialized")
    
    try:
        # Save temp file
        temp_file = f"temp_{file.filename}"
        with open(temp_file, "wb") as buffer:
            buffer.write(await file.read())
            
        result = model.transcribe(temp_file)
        os.remove(temp_file)
        
        return {"text": result["text"], "language": result.get("language")}
    except Exception as e:
        logger.error(f"Transcription error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
