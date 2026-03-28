from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    """V-JEPA Service Configuration"""
    
    # Service info
    service_name: str = "V-JEPA Embedding Service"
    service_version: str = "1.0.0"
    
    # Model configuration
    vjepa_model_name: str = "vit_base_patch16_224"
    device: str = os.getenv("DEVICE", "cuda" if os.getenv("CUDA_AVAILABLE") else "cpu")
    
    # API configuration
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    debug: bool = os.getenv("DEBUG", "false").lower() == "true"
    
    # Processing configuration
    default_fps: int = 2
    max_frames_per_video: Optional[int] = 300
    default_batch_size: int = 8
    max_upload_size_mb: int = 500
    
    # Database configuration (optional)
    db_host: Optional[str] = os.getenv("DB_HOST")
    db_port: Optional[int] = int(os.getenv("DB_PORT", 5432))
    db_user: Optional[str] = os.getenv("DB_USER")
    db_password: Optional[str] = os.getenv("DB_PASSWORD")
    db_name: Optional[str] = os.getenv("DB_NAME")
    
    # Logging
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    log_file: str = "/app/logs/vjepa_service.log"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# Initialize global settings
settings = Settings()
