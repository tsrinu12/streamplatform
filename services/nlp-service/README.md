# NLP Processing Service

A microservice for natural language processing with speech-to-text capabilities using OpenAI Whisper and advanced language understanding.

## Features

- **Speech-to-Text**: Convert audio to text using OpenAI Whisper
- **Multilingual Support**: Process content in multiple languages (Hindi, Telugu, Tamil, English, etc.)
- **Text Analysis**: Sentiment analysis and content classification
- **Named Entity Recognition**: Extract key entities from text
- **Health Monitoring**: Built-in health check endpoints for Kubernetes readiness/liveness

## API Endpoints

- `POST /transcribe` - Transcribe audio to text
- `POST /analyze` - Analyze text sentiment and extract entities
- `GET /health` - Service health status

## Tech Stack

- FastAPI
- OpenAI Whisper
- Transformers (Hugging Face)
- NLTK / spaCy
- Docker & Kubernetes

## Configuration

Environment variables:
- `WHISPER_MODEL` - Whisper model size (tiny, small, medium, large)
- `LANGUAGE` - Default language for processing
- `LOG_LEVEL` - Logging level

## Development

Install dependencies:
```bash
pip install -r requirements.txt
```

Run locally:
```bash
uvicorn app.main:app --reload
```

## Deployment

Build Docker image:
```bash
docker build -t nlp-service:latest .
```

Run container:
```bash
docker run -p 8000:8000 nlp-service:latest
```
