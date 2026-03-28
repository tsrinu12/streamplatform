import os
from fastapi import FastAPI, HTTPException
from sentence_transformers import SentenceTransformer
import pinecone
from loguru import logger

app = FastAPI(title="Semantic Search Service")

# Model and Index initialization
model = None
index = None

@app.on_event("startup")
async def startup_event():
    global model, index
    logger.info("Initializing SentenceTransformer...")
    model = SentenceTransformer('all-MiniLM-L6-v2')
    
    # Optional Pinecone init if env vars exist
    api_key = os.getenv("PINECONE_API_KEY")
    environment = os.getenv("PINECONE_ENV")
    if api_key and environment:
        pinecone.init(api_key=api_key, environment=environment)
        index_name = "streaming-content"
        if index_name not in pinecone.list_indexes():
            pinecone.create_index(index_name, dimension=384)
        index = pinecone.Index(index_name)
        logger.info("Pinecone index connected.")

@app.get("/search")
async def search(query: str, top_k: int = 5):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    query_vector = model.encode(query).tolist()
    
    if index:
        results = index.query(query_vector, top_k=top_k, include_metadata=True)
        return {"results": results}
    else:
        # Fallback or local search logic
        return {"query_vector_preview": query_vector[:5], "info": "Connect Pinecone for full search"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
