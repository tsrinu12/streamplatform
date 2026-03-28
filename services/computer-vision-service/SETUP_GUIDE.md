# Setup Guide: Computer Vision Service

## Prerequisites
- Python 3.9+
- Docker & Docker Compose
- NVIDIA GPU with CUDA (optional, for performance)

## Local Development Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Download Model
The service will automatically download the default YOLOv8n model on first startup. To use a specific model:
```bash
export MODEL_NAME=yolov8s.pt
```

### 3. Run Service
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Docker Deployment

### 1. Build Image
```bash
docker build -t computer-vision-service .
```

### 2. Run Container
```bash
docker run -p 8000:8000 computer-vision-service
```

## Testing
Send a sample video file to the service:
```bash
curl -X POST \"http://localhost:8000/process-video?fps=1\" \\
     -F \"file=@sample_video.mp4\"
```
