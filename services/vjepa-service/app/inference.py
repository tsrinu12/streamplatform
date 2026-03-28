import torch
import torchvision.transforms as transforms
import cv2
import numpy as np
import timm
from typing import List, Tuple

class VJEPAEmbeddingService:
    def __init__(self, model_name: str = "vit_base_patch16_224", device: str = "cpu"):
        self.device = device
        self.model = timm.create_model(model_name, pretrained=True)
        self.model = self.model.to(self.device)
        self.model.eval()
        
        self.transform = transforms.Compose([
            transforms.ToPILImage(),
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def video_to_embeddings(self, video_path: str, fps: int = 2) -> Tuple[np.ndarray, List[float]]:
        cap = cv2.VideoCapture(video_path)
        video_fps = cap.get(cv2.CAP_PROP_FPS)
        interval = int(video_fps / fps) if video_fps > 0 else 1
        
        frames = []
        timestamps = []
        count = 0
        while True:
            ret, frame = cap.read()
            if not ret: break
            if count % interval == 0:
                frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frames.append(self.transform(frame_rgb))
                timestamps.append(count / video_fps)
            count += 1
        cap.release()
        
        if not frames: return np.array([]), []
        
        batch = torch.stack(frames).to(self.device)
        with torch.no_grad():
            features = self.model.forward_features(batch)
            embeddings = features[:, 0, :].cpu().numpy()
            
        return embeddings, timestamps
