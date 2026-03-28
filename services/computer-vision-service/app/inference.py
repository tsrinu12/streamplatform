import cv2
import numpy as np
from ultralytics import YOLO
import torch
from typing import List, Dict, Any
from loguru import logger

class ComputerVisionService:
    def __init__(self, model_name: str = \"yolov8n.pt\", device: str = \"cpu\"):
        self.device = device
        self.model = YOLO(model_name)
        self.model.to(self.device)
        logger.info(f\"YOLOv8 model {model_name} loaded on {device}\")

    def process_video(self, video_path: str, fps: int = 1) -> List[Dict[str, Any]]:
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            logger.error(f\"Could not open video: {video_path}\")
            return []
            
        video_fps = cap.get(cv2.CAP_PROP_FPS)
        if video_fps == 0:
            video_fps = 30.0
            
        interval = max(1, int(video_fps / fps))
        
        results = []
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            if frame_count % interval == 0:
                timestamp = frame_count / video_fps
                # Run inference
                prediction = self.model(frame, verbose=False)[0]
                
                detections = []
                for box in prediction.boxes:
                    detections.append({
                        \"class\": prediction.names[int(box.cls)],
                        \"confidence\": float(box.conf),
                        \"bbox\": box.xyxy[0].tolist()
                    })
                
                if detections:
                    results.append({
                        \"timestamp\": timestamp,
                        \"detections\": detections
                    })
            
            frame_count += 1
            
        cap.release()
        return results
