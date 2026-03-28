# V-JEPA Embedding Service

## Overview

V-JEPA (Video Joint-Embedding Predictive Architecture) is Meta's self-supervised learning approach for video understanding. This service provides fast, scalable video embedding generation for your OTT platform.

## Features

- **Fast Video Embeddings**: Generate 768-dimensional embeddings from video frames
- **Content Discovery**: Enable cross-lingual and multilingual content recommendations
- **Smart Thumbnails**: Identify and extract most engaging moments from videos
- **Scalable Architecture**: Built with FastAPI and PyTorch for production-grade performance
- **Docker Support**: Runs on GPU (CUDA 12.1) or CPU

## Quick Start

### Build Docker Image

```bash
cd services/vjepa-service
docker build -t vjepa-service:latest .
```

### Run Service

```bash
docker run -p 8000:8000 \
  -e DEVICE=cuda \
  -v /path/to/videos:/videos \
  vjepa-service:latest
```

### API Endpoints

#### Health Check
```bash
GET /health
```

#### Embed Video
```bash
POST /embed-video
Content-Type: multipart/form-data

Parameters:
- file: Video file (MP4, MKV, etc.)
- fps: Frames per second (default: 2)
- max_frames: Max frames to process
- batch_size: Inference batch size (default: 8)
```

#### Calculate Similarity
```bash
POST /similarity
Content-Type: application/json

{
  "embedding1": [...],
  "embedding2": [...]
}
```

## Integration with StreamPlatform

Add to `docker-compose.yml`:

```yaml
vjepa-service:
  build: ./services/vjepa-service
  ports:
    - "8001:8000"
  environment:
    - DEVICE=cuda
    - DEBUG=false
  volumes:
    - ./services/vjepa-service/logs:/app/logs
```

## Configuration

Edit `config/settings.py` or set environment variables:

- `DEVICE`: `cuda` or `cpu`
- `LOG_LEVEL`: `INFO`, `DEBUG`, `WARNING`
- `DB_HOST`: PostgreSQL host for embedding storage

## Performance

- Model: ViT-Base-Patch16 (224x224)
- Embedding Dimension: 768
- GPU Memory: ~2-3 GB for batch processing
- Processing Speed: ~20-30 frames/sec on V100 GPU

## Use Cases

1. **Content Recommendations**: Similar video discovery
2. **Cross-Lingual Search**: Visual understanding beyond language
3. **Highlight Detection**: Automatic promo clip generation
4. **Content Moderation**: Visual feature extraction for safety

## Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## License

MIT
