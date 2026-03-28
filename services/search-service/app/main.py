import os
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
import pinecone
from loguru import logger

# Configuration
MODEL_NAME = os.getenv(\"MODEL_NAME\", \"all-MiniLM-L6-v2\")
PINECONE_API_KEY = os.getenv(\"PINECONE_API_KEY\")
PINECONE_ENV = os.getenv(\"PINECONE_ENV\")
INDEX_NAME = os.getenv(\"INDEX_NAME\", \"streaming-content\")

app = FastAPI(
    title=\"Search Discovery Service\",
    description=\"Semantic search service using DPR/ColBERT patterns with Pinecone\",
    version=\"1.0.0\"
)

# Global state
model = None
index = None

class SearchResult(BaseModel):
    id: str
    score: float
    metadata: Optional[dict] = None

class SearchResponse(BaseModel):
    query: str
    results: List[SearchResult]

@app.on_event(\"startup\")
async def startup_event():
    global model, index
    try:
        logger.info(f\"Initializing model: {MODEL_NAME}...\")
        model = SentenceTransformer(MODEL_NAME)
        
        if PINECONE_API_KEY and PINECONE_ENV:
            logger.info(\"Initializing Pinecone...\")
            pinecone.init(api_key=PINECONE_API_KEY, environment=PINECONE_ENV)
            
            if INDEX_NAME not in pinecone.list_indexes():
                logger.info(f\"Creating index: {INDEX_NAME}\")
                pinecone.create_index(INDEX_NAME, dimension=384)
            
            index = pinecone.Index(INDEX_NAME)
            logger.info(\"Pinecone index connected.\")
        else:
            logger.warning(\"Pinecone credentials missing. Search will return mock results.\")
    except Exception as e:
        logger.error(f\"Startup failed: {e}\")

@app.get(\"/health\")
async def health_check():
    return {
        \"status\": \"healthy\",
        \"model_loaded\": model is not None,
        \"index_connected\": index is not None
    }

@app.get(\"/search\", response_model=SearchResponse)
async def search(
    query: str = Query(..., description=\"The search query\"),
    top_k: int = Query(5, ge=1, le=100)
):
    if model is None:
        raise HTTPException(status_code=503, detail=\"Model not loaded\")

    try:
        # Generate embedding (DPR/Bi-encoder approach)
        query_embedding = model.encode(query).tolist()
        
        if index:
            results = index.query(vector=query_embedding, top_k=top_k, include_metadata=True)
            formatted_results = [
                SearchResult(id=match.id, score=match.score, metadata=match.metadata)
                for match in results.matches
            ]
        else:
            # Mock results if no index
            formatted_results = [
                SearchResult(id=f\"mock-{i}\", score=0.9, metadata={\"title\": f\"Result {i}\"})
                for i in range(top_k)
            ]
            
        return SearchResponse(query=query, results=formatted_results)
    except Exception as e:
        logger.error(f\"Search failed: {e}\")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == \"__main__\":
    import uvicorn
    uvicorn.run(app, host=\"0.0.0.0\", port=8000)
