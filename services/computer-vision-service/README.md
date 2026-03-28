# Computer Vision Service

## Overview
The Computer Vision Service provides real-time video analysis and object detection capabilities for the StreamPlatform. It utilizes YOLOv8 (You Only Look Once) from Ultralytics to identify objects, scenes, and events within video content.

## Features
- **Object Detection**: Detect over 80 classes of objects in video frames.
- **Scene Understanding**: Identify context and environment within video segments.
- **Timestamped Metadata**: Generate JSON results with precise timestamps for searchable video content.
- **Scalable Processing**: High-performance inference optimized for both CPU and GPU (CUDA).

## Architecture
- **Framework**: FastAPI
- **Model**: YOLOv8n (default)
- **Engine**: PyTorch / Ultralytics
- **Infrastructure**: Dockerized microservice

## API Endpoints
- `POST /process-video`: Upload an MP4 video for inference.
- `GET /health`: Service health and model status.

## Configuration
Environment variables:
- `MODEL_NAME`: YOLOv8 model file (e.g., `yolov8n.pt`).
- `DEVICE`: `cpu` or `cuda`.
- `CONFIDENCE_THRESHOLD`: Minimum confidence for detections (default: 0.25).
