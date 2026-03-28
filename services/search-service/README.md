# Search Discovery Service

A microservice for semantic search using Dense Passage Retrieval (DPR) and ColBERT-style late interaction patterns.

## Features
- **Semantic Search**: Uses `SentenceTransformer` (Bi-encoder) for high-speed vector retrieval.
- **Vector Database**: Integrated with Pinecone for scalable similarity search.
- **DPR/ColBERT Ready**: Implements embeddings compatible with dense retrieval workflows.
- **Health Monitoring**: Built-in health check endpoints for Kubernetes readiness/liveness.

## API Endpoints
- `GET /search?query={text}&top_k=5`: Perform semantic search.
- `GET /health`: Service health status.

## Tech Stack
- FastAPI
- PyTorch / Sentence-Transformers
- Pinecone
- Docker & Kubernetes
