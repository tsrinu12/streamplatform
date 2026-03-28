FROM pytorch/pytorch:2.1.0-cuda12.1-runtime-ubuntu22.04

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    libgl1-mesa-glx \\
    libglib2.0-0 \\
    ffmpeg \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY config/ ./config/

# Create non-root user for security
RUN useradd -m -u 1000 cv_user && chown -R cv_user:cv_user /app
USER cv_user

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \\
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Command to run the service
CMD [\"uvicorn\", \"app.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]
