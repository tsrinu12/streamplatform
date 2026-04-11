# AI Service Dockerfile - Multi-stage build with pinned Python version
# Fixes: Pinned Python base image version, health check, security hardening

# ==============================================================================
# Stage 1: Builder
# ==============================================================================
# Pin to specific Python version for security and reproducibility
FROM python:3.11.6-slim-bookworm AS base

WORKDIR /app

# Install build dependencies in a single layer to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies without cache
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# ==============================================================================
# Stage 2: Production (Minimal image)
# ==============================================================================
# Pin to specific Python version
FROM python:3.11.6-slim-bookworm AS production

WORKDIR /app

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy site-packages from builder
COPY --from=base --chown=appuser:appuser /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy application code from builder
COPY --from=base --chown=appuser:appuser /app /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8000

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Start the FastAPI application
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
