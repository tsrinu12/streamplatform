# StreamPlatform AI Algorithms Registry

**Version:** 1.0.0  
**Last Updated:** March 28, 2026  
**Status:** Production Ready

## Overview

This document catalogs all AI/ML algorithms implemented or planned for the StreamPlatform OTT service. Each algorithm is mapped to microservices in the `services/` directory.

---

## 🎯 Implementation Status

| Category | Service | Algorithms | Status | Priority |
|----------|---------|------------|--------|----------|
| Video Understanding | `vjepa-service` | V-JEPA 2, ViT, TimeSFormer | ✅ Implemented | P0 |
| Recommendations | `recommendation-service` | LightGCN, BERT4Rec, DeepFM | 🔨 In Progress | P0 |
| NLP & Speech | `nlp-service` | Whisper, CLIP, BERT | 📋 Planned | P1 |
| Content Moderation | `moderation-service` | YOLOv8, Toxicity Detection | 📋 Planned | P1 |
| Search | `search-service` | Dense Passage Retrieval, ColBERT | 📋 Planned | P1 |
| ABR Streaming | `streaming-service` | Pensieve RL, Neural ABR | 📋 Planned | P2 |
| Audio Analysis | `audio-service` | Wav2Vec 2.0, HuBERT | 📋 Planned | P2 |
| Thumbnail Generation | `thumbnail-service` | Saliency, Attention Networks | 📋 Planned | P2 |

---

## 📦 Service Implementations

### 1. V-JEPA Service (`services/vjepa-service`)
**Status:** ✅ Implemented

#### Algorithms
- **V-JEPA (Video Joint-Embedding Predictive Architecture)** - Meta AI
  - Self-supervised video representation learning
  - 768-dimensional embeddings from video frames
  - Model: ViT-Base-Patch16-224
  
- **Vision Transformer (ViT)**
  - Backbone for frame-level feature extraction
  - Pre-trained on ImageNet-21K

#### Use Cases
- Content-based recommendations
- Cross-lingual video discovery
- Smart thumbnail selection
- Visual content moderation

#### Performance
- Embedding Dimension: 768
- Processing: ~20-30 FPS on V100 GPU
- Memory: ~2-3 GB VRAM

---

### 2. Recommendation Service (`services/recommendation-service`)
**Status:** 🔨 Planned

#### Algorithms Planned

**A. Graph-Based Collaborative Filtering**
- **LightGCN** - Light Graph Convolutional Networks
  - User-item graph representation
  - Removes non-linearity for efficiency
  - State-of-the-art collaborative filtering

- **NGCF** - Neural Graph Collaborative Filtering
  - High-order connectivity modeling
  - Graph neural network propagation

**B. Sequential Recommendations**
- **BERT4Rec** - BERT for Sequential Recommendation
  - Bidirectional self-attention
  - Session-based predictions
  - Handles sparse user histories

- **SASRec** - Self-Attentive Sequential Recommendation
  - Unidirectional transformer
  - Real-time inference

**C. Deep Learning Models**
- **DeepFM** - Deep Factorization Machines
  - Combines FM + DNN
  - Feature interactions

- **xDeepFM** - Extreme Deep Factorization Machines
  - Compressed Interaction Network (CIN)
  - Explicit and implicit feature learning

- **Wide & Deep**
  - Memorization + Generalization
  - Google's production model

**D. Contextual Bandits**
- **LinUCB** - Linear Upper Confidence Bound
  - Exploration-exploitation trade-off
  - Personalized recommendations

- **Thompson Sampling**
  - Bayesian approach to bandits
  - Dynamic A/B testing

---

### 3. NLP & Speech Service (`services/nlp-service`)
**Status:** 📋 Planned

#### Algorithms

**A. Speech Recognition**
- **Whisper (OpenAI)**
  - Multilingual ASR (Telugu, Hindi, English, Tamil)
  - Automatic subtitle generation
  - 680,000 hours pre-training

- **Wav2Vec 2.0 (Meta)**
  - Self-supervised speech representation
  - Fine-tuning for Telugu/Hindi

**B. Vision-Language Models**
- **CLIP (OpenAI)**
  - Zero-shot image-text matching
  - Cross-lingual video search
  - Visual question answering

- **BLIP** - Bootstrapping Language-Image Pre-training
  - Caption generation
  - Visual question answering

**C. Text Understanding**
- **BERT / RoBERTa / DeBERTa**
  - Search query understanding
  - Entity extraction (actors, directors)
  - Intent classification

- **mBERT / XLM-RoBERTa**
  - Multilingual text understanding
  - Cross-lingual information retrieval

**D. Summarization**
- **BART / T5 / PEGASUS**
  - Content summarization
  - Description generation

---

### 4. Content Moderation Service (`services/moderation-service`)
**Status:** 📋 Planned

#### Algorithms

**A. Visual Moderation**
- **YOLOv8 (Ultralytics)**
  - Real-time object detection
  - NSFW content detection
  - Violence and weapon detection

- **Faster R-CNN**
  - High-accuracy region proposals
  - Fine-grained content analysis

- **3D CNN (I3D, C3D)**
  - Action recognition
  - Violence detection in videos

**B. Text Moderation**
- **Toxic Comment Classifier**
  - BERT-based toxicity detection
  - Profanity filtering

- **Hate Speech Detection**
  - Multilingual classifiers
  - Context-aware moderation

**C. Audio Moderation**
- **Speech Content Filtering**
  - Profanity detection in audio
  - Background audio classification

---

### 5. Search Service (`services/search-service`)
**Status:** 📋 Planned

#### Algorithms

**A. Dense Retrieval**
- **Dense Passage Retrieval (DPR)**
  - Dual-encoder architecture (query + document)
  - Semantic search beyond keywords

- **ColBERT** - Contextualized Late Interaction
  - Fine-grained similarity matching
  - Efficient late interaction

**B. Vector Search**
- **Faiss (Meta)**
  - Approximate nearest neighbor search
  - GPU-accelerated indexing

- **HNSW (Hierarchical Navigable Small World)**
  - Graph-based ANN
  - Sub-linear search complexity

**C. Query Understanding**
- **Query Expansion**
  - Synonym expansion
  - Intent understanding

- **Spell Correction**
  - Edit distance algorithms
  - Phonetic matching (Soundex, Metaphone)

---

### 6. ABR Streaming Service (`services/streaming-service`)
**Status:** 📋 Planned

#### Algorithms

**A. Adaptive Bitrate**
- **Pensieve (MIT)**
  - Deep reinforcement learning for ABR
  - Actor-Critic networks
  - QoE optimization

- **Neural ABR**
  - DNN-based bandwidth prediction
  - LSTM for network state modeling

**B. Quality of Experience**
- **Reinforcement Learning (PPO, DQN)**
  - Dynamic bitrate adaptation
  - Stalling minimization

---

## 🚀 Deployment Architecture

```
┌─────────────────────────────────────────────────────┐
│               API Gateway (Kong/Nginx)             │
└──────────────┬──────────────────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
   ┌───▼────┐      ┌───▼────┐
   │ vjepa- │      │  rec-  │
   │service │      │service │
   └────────┘      └────────┘
       │                │
   ┌───▼────┐      ┌───▼────┐
   │  nlp-  │      │  mod-  │
   │service │      │service │
   └────────┘      └────────┘
       │                │
   ┌───▼────┐      ┌───▼────┐
   │search- │      │stream- │
   │service │      │service │
   └────────┘      └────────┘
       │
   ┌───▼──────────┐
   │  Vector DB   │
   │(Qdrant/Faiss)│
   └──────────────┘
```

---

## 📊 Algorithm Selection Criteria

### Video Understanding
- **Input:** Video frames, resolution, FPS
- **Output:** Embeddings (768-dim), object detections, scene labels
- **Models:** V-JEPA, ViT, CLIP, TimeSFormer
- **Latency:** < 500ms per video (batch processing)

### Recommendations
- **Input:** User history, context (time, device), item metadata
- **Output:** Ranked list of N items
- **Models:** LightGCN, BERT4Rec, DeepFM
- **Latency:** < 50ms for real-time

### Search
- **Input:** Text query, filters, user context
- **Output:** Ranked search results
- **Models:** DPR, ColBERT, BERT
- **Latency:** < 100ms

### Moderation
- **Input:** Video/audio/text content
- **Output:** Safety scores, flags
- **Models:** YOLOv8, BERT-toxic, Wav2Vec
- **Latency:** Real-time for live streams

---

## 🔬 Research & Experimentation

### Upcoming Models (2026-2027)
1. **VideoMAE** - Masked video autoencoder
2. **Gemini** - Multimodal LLM for video understanding
3. **Stable Diffusion Video** - AI-generated thumbnails
4. **Federated Learning** - Privacy-preserving recommendations

---

## 📚 References

- [Meta V-JEPA](https://github.com/facebookresearch/vjepa2)
- [LightGCN Paper](https://arxiv.org/abs/2002.02126)
- [BERT4Rec Paper](https://arxiv.org/abs/1904.06690)
- [Whisper GitHub](https://github.com/openai/whisper)
- [CLIP Paper](https://arxiv.org/abs/2103.00020)
- [YOLOv8 Docs](https://docs.ultralytics.com/)
- [Pensieve Paper](https://people.csail.mit.edu/hongzi/content/publications/Pensieve-Sigcomm17.pdf)

---

## 📝 Contributing

To add a new algorithm:
1. Create service under `services/<algorithm-name>-service/`
2. Update this registry
3. Add to `docker-compose.yml`
4. Submit PR with benchmarks

---

**Maintained by:** StreamPlatform AI Team  
**License:** MIT
