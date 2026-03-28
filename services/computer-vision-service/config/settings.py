import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    service_name: str = \"Computer Vision Service\"
    service_version: str = \"1.0.0\"
    model_name: str = os.getenv(\"MODEL_NAME\", \"yolov8n.pt\")
    device: str = os.getenv(\"DEVICE\", \"cpu\")
    confidence_threshold: float = float(os.getenv(\"CONFIDENCE_THRESHOLD\", 0.25))

    class Config:
        env_file = \".env\"

settings = Settings()
