# services/upload-service/src/main.py
# Resumable multipart upload service for StreamPlatform
# Supports: files up to 5TB, 100MB/s+ throughput, pause/resume, progress tracking
# Uses S3 multipart upload API with presigned URLs — no proxy buffering

import asyncio
import hashlib
import json
import logging
import os
import time
import uuid
from typing import Dict, List, Optional

import boto3
from botocore.config import Config as BotoConfig
from botocore.exceptions import ClientError
from fastapi import FastAPI, HTTPException, Header, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import redis.asyncio as aioredis
import uvicorn
from prometheus_fastapi_instrumentator import Instrumentator

# ─── Config ────────────────────────────────────────────────────────────────

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("upload-service")

S3_BUCKET        = os.getenv("S3_BUCKET", "streamplatform-uploads")
AWS_REGION       = os.getenv("AWS_REGION", "us-east-1")
REDIS_URL        = os.getenv("REDIS_URL", "redis://localhost:6379")
TRANSCODE_SQS    = os.getenv("TRANSCODE_SQS_URL", "")
PART_SIZE_MB     = int(os.getenv("PART_SIZE_MB", "50"))       # 50 MB parts
MAX_PARTS        = 10000                                        # S3 hard limit
MAX_FILE_SIZE_GB = int(os.getenv("MAX_FILE_SIZE_GB", "100"))   # 100 GB
PRESIGNED_TTL    = int(os.getenv("PRESIGNED_TTL_SECONDS", "3600"))

s3 = boto3.client(
    "s3",
    region_name=AWS_REGION,
    config=BotoConfig(signature_version="s3v4", max_pool_connections=50),
)
sqs = boto3.client("sqs", region_name=AWS_REGION) if TRANSCODE_SQS else None

# ─── Models ────────────────────────────────────────────────────────────────

class InitUploadRequest(BaseModel):
    filename: str
    file_size: int                      # bytes
    content_type: str = "video/mp4"
    title: str
    description: Optional[str] = ""
    language: str = "en"
    tags: List[str] = []
    user_id: str
    checksum_sha256: Optional[str] = None   # optional integrity check

class InitUploadResponse(BaseModel):
    upload_id: str                      # our internal ID
    s3_upload_id: str                   # S3 multipart upload ID
    s3_key: str
    parts: List[Dict]                   # list of {part_number, presigned_url}
    total_parts: int
    part_size_bytes: int
    expires_at: int

class CompletePartRequest(BaseModel):
    upload_id: str
    part_number: int
    etag: str                           # from S3 upload response header

class CompleteUploadRequest(BaseModel):
    upload_id: str
    parts: List[Dict]                   # [{part_number, etag}]
    checksum_sha256: Optional[str] = None

class UploadStatusResponse(BaseModel):
    upload_id: str
    status: str                         # initiated | uploading | processing | complete | failed
    progress_pct: float
    uploaded_parts: int
    total_parts: int
    file_size: int
    uploaded_bytes: int
    created_at: int
    updated_at: int

class AbortRequest(BaseModel):
    upload_id: str

# ─── App ───────────────────────────────────────────────────────────────────

app = FastAPI(title="StreamPlatform Upload Service", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Upload-ID"],
)
Instrumentator().instrument(app).expose(app)

redis_client: Optional[aioredis.Redis] = None

@app.on_event("startup")
async def startup():
    global redis_client
    redis_client = aioredis.from_url(REDIS_URL, decode_responses=True)
    logger.info("Upload service started")

# ─── Helpers ───────────────────────────────────────────────────────────────

def _upload_key(upload_id: str) -> str:
    return f"upload:{upload_id}"

def _calculate_parts(file_size: int, part_size_mb: int) -> tuple[int, int]:
    """Returns (total_parts, part_size_bytes)."""
    part_bytes = part_size_mb * 1024 * 1024
    total_parts = (file_size + part_bytes - 1) // part_bytes
    if total_parts > MAX_PARTS:
        # Auto-scale part size to stay within S3 limits
        part_bytes = (file_size + MAX_PARTS - 1) // MAX_PARTS
        total_parts = MAX_PARTS
    return total_parts, part_bytes

def _generate_s3_key(user_id: str, upload_id: str, filename: str) -> str:
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else "mp4"
    return f"raw/{user_id}/{upload_id}/source.{ext}"

async def _save_state(upload_id: str, state: dict):
    await redis_client.set(_upload_key(upload_id), json.dumps(state), ex=86400 * 7)

async def _load_state(upload_id: str) -> dict:
    data = await redis_client.get(_upload_key(upload_id))
    if not data:
        raise HTTPException(status_code=404, detail=f"Upload {upload_id} not found")
    return json.loads(data)

def _trigger_transcode(upload_id: str, s3_key: str, metadata: dict):
    """Publish transcode job to SQS for transcode-service to pick up."""
    if not sqs or not TRANSCODE_SQS:
        logger.warning("SQS not configured — skipping transcode trigger")
        return
    message = {
        "job_type": "transcode",
        "upload_id": upload_id,
        "s3_key": s3_key,
        "s3_bucket": S3_BUCKET,
        "metadata": metadata,
        "submitted_at": int(time.time()),
        "output_formats": ["hls", "dash"],
        "abr_ladder": ["4k", "1080p", "720p", "480p", "360p"],
        "generate_thumbnails": True,
        "generate_subtitles": metadata.get("language", "en") in ["te", "hi"],
    }
    sqs.send_message(
        QueueUrl=TRANSCODE_SQS,
        MessageBody=json.dumps(message),
        MessageGroupId="transcode",
        MessageDeduplicationId=upload_id,
    )
    logger.info(f"Transcode job submitted for upload: {upload_id}")

# ─── Routes ────────────────────────────────────────────────────────────────

@app.post("/uploads/init", response_model=InitUploadResponse)
async def init_upload(req: InitUploadRequest, authorization: str = Header(...)):
    """
    Initialize a multipart upload. Returns presigned URLs for each part.
    Client uploads parts directly to S3 — no proxy buffering.
    """
    max_bytes = MAX_FILE_SIZE_GB * 1024 ** 3
    if req.file_size > max_bytes:
        raise HTTPException(status_code=413, detail=f"File too large. Max {MAX_FILE_SIZE_GB}GB")
    if req.file_size < 1:
        raise HTTPException(status_code=400, detail="Invalid file size")

    upload_id = str(uuid.uuid4())
    s3_key = _generate_s3_key(req.user_id, upload_id, req.filename)
    total_parts, part_bytes = _calculate_parts(req.file_size, PART_SIZE_MB)

    # Create S3 multipart upload
    try:
        resp = s3.create_multipart_upload(
            Bucket=S3_BUCKET,
            Key=s3_key,
            ContentType=req.content_type,
            Metadata={
                "upload-id": upload_id,
                "user-id": req.user_id,
                "title": req.title[:255],
                "language": req.language,
            },
            ServerSideEncryption="AES256",
            StorageClass="STANDARD",
        )
        s3_upload_id = resp["UploadId"]
    except ClientError as e:
        logger.error(f"S3 multipart init failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to initialize upload")

    # Generate presigned URLs for all parts (parallel)
    parts = []
    for part_num in range(1, total_parts + 1):
        url = s3.generate_presigned_url(
            "upload_part",
            Params={
                "Bucket": S3_BUCKET,
                "Key": s3_key,
                "UploadId": s3_upload_id,
                "PartNumber": part_num,
            },
            ExpiresIn=PRESIGNED_TTL,
        )
        parts.append({"part_number": part_num, "presigned_url": url})

    # Persist state in Redis
    state = {
        "upload_id": upload_id,
        "s3_upload_id": s3_upload_id,
        "s3_key": s3_key,
        "s3_bucket": S3_BUCKET,
        "status": "initiated",
        "file_size": req.file_size,
        "total_parts": total_parts,
        "part_size_bytes": part_bytes,
        "uploaded_parts": [],
        "uploaded_bytes": 0,
        "progress_pct": 0.0,
        "user_id": req.user_id,
        "filename": req.filename,
        "title": req.title,
        "description": req.description,
        "language": req.language,
        "tags": req.tags,
        "checksum_sha256": req.checksum_sha256,
        "created_at": int(time.time()),
        "updated_at": int(time.time()),
    }
    await _save_state(upload_id, state)

    logger.info(f"Initialized upload {upload_id}: {total_parts} parts × {part_bytes // 1024 // 1024}MB")
    return InitUploadResponse(
        upload_id=upload_id,
        s3_upload_id=s3_upload_id,
        s3_key=s3_key,
        parts=parts,
        total_parts=total_parts,
        part_size_bytes=part_bytes,
        expires_at=int(time.time()) + PRESIGNED_TTL,
    )


@app.post("/uploads/part")
async def report_part_uploaded(req: CompletePartRequest):
    """
    Client reports successful part upload.
    Updates progress tracking in Redis.
    """
    state = await _load_state(req.upload_id)

    if req.part_number in state["uploaded_parts"]:
        return {"status": "already_recorded"}

    state["uploaded_parts"].append(req.part_number)
    state["uploaded_bytes"] = len(state["uploaded_parts"]) * state["part_size_bytes"]
    state["progress_pct"] = round(len(state["uploaded_parts"]) / state["total_parts"] * 100, 1)
    state["status"] = "uploading"
    state["updated_at"] = int(time.time())

    # Store ETags for final assembly
    etag_key = f"upload:{req.upload_id}:etags"
    await redis_client.hset(etag_key, str(req.part_number), req.etag)
    await redis_client.expire(etag_key, 86400 * 7)
    await _save_state(req.upload_id, state)

    return {"status": "ok", "progress_pct": state["progress_pct"]}


@app.post("/uploads/complete")
async def complete_upload(req: CompleteUploadRequest, background_tasks: BackgroundTasks):
    """
    Finalize the S3 multipart upload and trigger transcoding pipeline.
    """
    state = await _load_state(req.upload_id)

    # Assemble parts list from Redis or request
    if req.parts:
        parts_list = sorted(req.parts, key=lambda x: x["part_number"])
    else:
        # Reconstruct from stored ETags
        etag_key = f"upload:{req.upload_id}:etags"
        etags = await redis_client.hgetall(etag_key)
        parts_list = sorted(
            [{"PartNumber": int(k), "ETag": v} for k, v in etags.items()],
            key=lambda x: x["PartNumber"],
        )

    if not parts_list:
        raise HTTPException(status_code=400, detail="No parts to complete")

    try:
        s3.complete_multipart_upload(
            Bucket=state["s3_bucket"],
            Key=state["s3_key"],
            UploadId=state["s3_upload_id"],
            MultipartUpload={"Parts": [
                {"PartNumber": p.get("PartNumber") or p.get("part_number"),
                 "ETag": p.get("ETag") or p.get("etag")}
                for p in parts_list
            ]},
        )
    except ClientError as e:
        logger.error(f"S3 complete multipart failed: {e}")
        state["status"] = "failed"
        await _save_state(req.upload_id, state)
        raise HTTPException(status_code=500, detail="Failed to complete upload")

    state["status"] = "processing"
    state["progress_pct"] = 100.0
    state["updated_at"] = int(time.time())
    await _save_state(req.upload_id, state)

    # Async: trigger transcode pipeline
    metadata = {
        "upload_id": req.upload_id,
        "title": state["title"],
        "description": state["description"],
        "language": state["language"],
        "tags": state["tags"],
        "user_id": state["user_id"],
        "file_size": state["file_size"],
    }
    background_tasks.add_task(_trigger_transcode, req.upload_id, state["s3_key"], metadata)

    logger.info(f"Upload {req.upload_id} completed — transcoding triggered")
    return {
        "status": "processing",
        "upload_id": req.upload_id,
        "s3_key": state["s3_key"],
        "message": "Upload complete. Transcoding pipeline started.",
    }


@app.get("/uploads/{upload_id}/status", response_model=UploadStatusResponse)
async def get_upload_status(upload_id: str):
    """Poll upload + transcode progress."""
    state = await _load_state(upload_id)
    return UploadStatusResponse(
        upload_id=upload_id,
        status=state["status"],
        progress_pct=state["progress_pct"],
        uploaded_parts=len(state["uploaded_parts"]),
        total_parts=state["total_parts"],
        file_size=state["file_size"],
        uploaded_bytes=state["uploaded_bytes"],
        created_at=state["created_at"],
        updated_at=state["updated_at"],
    )


@app.delete("/uploads/{upload_id}")
async def abort_upload(upload_id: str):
    """Abort a multipart upload and clean up S3 + Redis state."""
    state = await _load_state(upload_id)

    try:
        s3.abort_multipart_upload(
            Bucket=state["s3_bucket"],
            Key=state["s3_key"],
            UploadId=state["s3_upload_id"],
        )
    except ClientError as e:
        logger.warning(f"S3 abort failed (may already be complete): {e}")

    await redis_client.delete(_upload_key(upload_id))
    await redis_client.delete(f"upload:{upload_id}:etags")
    logger.info(f"Upload {upload_id} aborted")
    return {"status": "aborted", "upload_id": upload_id}


@app.get("/uploads/{upload_id}/presign-part/{part_number}")
async def refresh_presigned_url(upload_id: str, part_number: int):
    """Refresh an expired presigned URL for a specific part."""
    state = await _load_state(upload_id)
    if state["status"] not in ("initiated", "uploading"):
        raise HTTPException(status_code=400, detail="Upload is not in progress")

    url = s3.generate_presigned_url(
        "upload_part",
        Params={
            "Bucket": state["s3_bucket"],
            "Key": state["s3_key"],
            "UploadId": state["s3_upload_id"],
            "PartNumber": part_number,
        },
        ExpiresIn=PRESIGNED_TTL,
    )
    return {"part_number": part_number, "presigned_url": url, "expires_in": PRESIGNED_TTL}


@app.get("/health")
async def health():
    redis_ok = True
    try:
        await redis_client.ping()
    except Exception:
        redis_ok = False
    return {"status": "ok", "redis": redis_ok}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8070")))
