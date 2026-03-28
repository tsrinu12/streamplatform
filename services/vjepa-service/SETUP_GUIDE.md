# V-JEPA Service Setup Guide

## Prerequisites

- Docker & Docker Compose (v20.10+)
- NVIDIA Docker Runtime (for GPU support)
- GPU with CUDA 12.1 support (optional, CPU fallback available)
- 8GB+ available RAM

## File Structure

```
services/vjepa-service/
├── Dockerfile              # Multi-stage PyTorch + FastAPI image
├── requirements.txt        # Python dependencies
├── README.md              # Service overview & API docs
├── SETUP_GUIDE.md         # This file
├── config/
│   ├── __init__.py
│   └── settings.py        # Configuration management
└── app/
    ├── __init__.py
    ├── main.py            # FastAPI application (to be implemented)
    ├── inference.py       # V-JEPA model wrapper (to be implemented)
    └── models/            # Pre-trained weights (git-lfs)
```

## Quick Start

### 1. Build Docker Image

```bash
cd services/vjepa-service
docker build -t vjepa-service:latest .
```

### 2. Run with Docker Compose

Add to your `docker-compose.yml`:

```yaml
vjepa-service:
  build: ./services/vjepa-service
  container_name: vjepa-service
  ports:
    - "8001:8000"
  environment:
    - DEVICE=cuda          # or 'cpu'
    - DEBUG=false
    - LOG_LEVEL=INFO
  volumes:
    - ./services/vjepa-service/logs:/app/logs
  networks:
    - streamplatform-network
  restart: unless-stopped
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval: 30s
    timeout: 10s
    retries: 3

networks:
  streamplatform-network:
    driver: bridge
```

Then run:

```bash
docker-compose up vjepa-service
```

### 3. Test Service

```bash
# Health check
curl http://localhost:8001/health

# Expected response:
# {"status": "healthy", "model_loaded": true, "device": "cuda", "embedding_dim": 768}
```

## Configuration

Environment variables (or edit `config/settings.py`):

```bash
DEVICE=cuda              # Device: 'cuda' or 'cpu'
DEBUG=false              # Enable debug mode
LOG_LEVEL=INFO           # Logging level
DB_HOST=postgres         # (Optional) Database host
DB_PORT=5432             # (Optional) Database port
DB_USER=streamplatform   # (Optional) Database user
DB_PASSWORD=xxx          # (Optional) Database password
DB_NAME=embeddings       # (Optional) Embeddings storage DB
```

## Integration with Backend Services

### From Video Service

```python
import httpx

async def index_video_embeddings(video_id: str, video_path: str):
    """Extract and store embeddings for video"""
    async with httpx.AsyncClient() as client:
        with open(video_path, 'rb') as f:
            response = await client.post(
                'http://vjepa-service:8000/embed-video',
                files={'file': f},
                params={'fps': 2, 'batch_size': 8}
            )
        
        if response.status_code == 200:
            embeddings_data = response.json()
            # Store in PostgreSQL or vector database
            await store_embeddings(video_id, embeddings_data['embeddings'])
```

### From Recommendation Service

```python
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def find_similar_videos(video_embedding: List[float], top_k: int = 10):
    """Find similar videos using embeddings"""
    # Query vector database for k-nearest neighbors
    similar_ids = vector_db.search(video_embedding, k=top_k)
    return similar_ids
```

## Performance Tuning

### GPU Configuration

```bash
# Enable GPU in docker-compose.yml:
runtime: nvidia
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility
```

### Memory Management

```python
# Reduce batch size for limited VRAM
# curl -X POST http://localhost:8001/embed-video \
#   -F "file=@video.mp4" \
#   -F "batch_size=4"
```

### Multi-GPU Support

```dockerfile
# Modify Dockerfile for multi-GPU:
ENV CUDA_VISIBLE_DEVICES=0,1
```

## Troubleshooting

### CUDA Out of Memory

```bash
# Solution 1: Reduce batch size
-F "batch_size=2"

# Solution 2: Reduce max frames
-F "max_frames=100"

# Solution 3: Use CPU
DEVICE=cpu
```

### Model Download Issues

```bash
# Pre-download model weights
docker run --rm -it vjepa-service:latest python -c \
  "import timm; timm.create_model('vit_base_patch16_224', pretrained=True)"
```

### Connection Refused

```bash
# Verify service is running
docker ps | grep vjepa-service

# Check logs
docker logs vjepa-service

# Wait for service to fully initialize (30-60 seconds)
sleep 60 && curl http://vjepa-service:8000/health
```

## Production Deployment

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vjepa-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vjepa-service
  template:
    metadata:
      labels:
        app: vjepa-service
    spec:
      containers:
      - name: vjepa
        image: vjepa-service:latest
        ports:
        - containerPort: 8000
        resources:
          limits:
            nvidia.com/gpu: 1
          requests:
            memory: "4Gi"
            cpu: "2"
      nodeSelector:
        accelerator: gpu
```

### Load Balancing

```yaml
apiVersion: v1
kind: Service
metadata:
  name: vjepa-service
spec:
  type: LoadBalancer
  selector:
    app: vjepa-service
  ports:
  - port: 80
    targetPort: 8000
```

## Monitoring

```bash
# Check service metrics
curl http://vjepa-service:8000/metrics

# Monitor GPU usage
nvidia-smi -l 1

# Monitor container resources
docker stats vjepa-service
```

## Next Steps

1. **Implement `app/main.py`**: FastAPI endpoints for video embedding
2. **Implement `app/inference.py`**: V-JEPA model inference logic
3. **Add Vector Database Integration**: Store embeddings in Qdrant/Milvus
4. **Create Integration Tests**: Test V-JEPA with video-service
5. **Performance Benchmarking**: Measure throughput and latency

## References

- [Meta V-JEPA GitHub](https://github.com/facebookresearch/vjepa2)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [PyTorch Documentation](https://pytorch.org/docs/)
- [timm Model Zoo](https://github.com/huggingface/pytorch-image-models)
