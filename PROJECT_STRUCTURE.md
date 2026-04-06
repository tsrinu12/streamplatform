# StreamPlatform - Project Structure

Comprehensive directory structure documentation for the StreamPlatform monorepo.

Last Updated: April 6, 2026 | Repository: tsrinu12/streamplatform | Total Commits: 147+

---

## Overview

StreamPlatform is organized as a monorepo containing microservices, infrastructure-as-code (Terraform), Kubernetes manifests, Helm charts, CI/CD workflows, monitoring configurations, and documentation. The repository follows a production-grade structure with clear separation of concerns.

**Language Distribution:** HCL 60.0%, Python 16.8%, Shell 9.1%, Dockerfile 6.0%, PLpgSQL 3.3%, JavaScript 2.7%, Makefile 2.1%

---

## Root Level Structure

### Directories

| Directory | Description | Status |
|-----------|-------------|--------|
| `.github/workflows/` | GitHub Actions CI/CD pipelines | Implemented |
| `db/migrations/` | PostgreSQL database migrations | Implemented |
| `helm/streamplatform/` | Helm charts for Kubernetes deployment | Implemented |
| `k8s/` | Raw Kubernetes manifests and configs | Implemented |
| `loadtest/k6/` | K6 load testing scripts | Implemented |
| `monitoring/` | Prometheus, Grafana, alerting rules | Implemented |
| `scripts/` | Deployment and automation scripts | Implemented |
| `services/` | 10 AI-powered microservices | Implemented |
| `terraform/` | Terraform IaC modules and environments | Implemented |

### Root Files

| File | Description | Status |
|------|-------------|--------|
| `.env.example` | Environment variables template | Implemented |
| `.gitignore` | Git ignore rules | Implemented |
| `docker-compose.test.yml` | Test environment Docker Compose | Implemented |
| `docker-compose.yml` | Local development Docker Compose | Implemented |
| `Makefile` | Build and deployment targets | Implemented |
| `package.json` | Root monorepo package config | Implemented |

### Documentation Files (.md)

| File | Description |
|------|-------------|
| `README.md` | Main project documentation and getting started |
| `AI_ALGORITHMS_REGISTRY.md` | AI algorithms used across services |
| `AWS_CLOUD_DEPLOYMENT.md` | AWS deployment guide |
| `CONTRIBUTING.md` | Contribution guidelines |
| `FILE_INVENTORY.md` | Complete file inventory |
| `IMPLEMENTATION_GUIDE.md` | Step-by-step implementation guide |
| `MICROSERVICES_AUDIT.md` | Microservices status audit |
| `MULTI_ENVIRONMENT_READINESS.md` | Multi-environment readiness report |
| `PROJECT_COMPLETION_STATUS.md` | Overall project completion dashboard |
| `PROJECT_STRUCTURE.md` | This file - directory structure |
| `SETUP_GUIDE.md` | Local setup instructions |
| `TIER_FILES_STRUCTURE.md` | Tier-based file organization |
| `TIER_IMPLEMENTATION_STATUS.md` | Tier implementation progress |

---

## services/ - Microservices

Contains 10 Python-based microservices, each with Dockerfile, requirements.txt, and service-specific code.

| Service | Purpose | Key Files |
|---------|---------|----------|
| `ai-service/` | Core AI processing and model inference | Dockerfile, main.py, requirements.txt |
| `auth-service/` | Authentication, JWT, user management | Dockerfile, auth logic |
| `computer-vision-service/` | Video frame analysis, object detection | Dockerfile, CV models |
| `nlp-service/` | NLP processing, sentiment, subtitles | Dockerfile, NLP pipelines |
| `notification-service/` | Push, email, SMS notifications | Dockerfile, notification logic |
| `recommendation-service/` | Personalized content recommendations | Dockerfile, ML models |
| `reward-service/` | Gamification and reward points | Dockerfile, reward logic |
| `search-service/` | Full-text and vector search | Dockerfile, search indexing |
| `transcode-service/` | Video transcoding and encoding | Dockerfile, ffmpeg integration |
| `video-service/` | Video upload, storage, streaming | Dockerfile, video processing |

---

## terraform/ - Infrastructure as Code

### terraform/modules/ (15 Modules)

| Module | Purpose | AWS Service |
|--------|---------|------------|
| `cloudfront/` | CDN distribution configuration | CloudFront |
| `cloudwatch/` | Logging and monitoring | CloudWatch |
| `documentdb/` | Document database cluster | DocumentDB |
| `ecr/` | Container registry repos | ECR |
| `eks/` | Kubernetes cluster provisioning | EKS |
| `elasticache/` | Redis/Memcached caching | ElastiCache |
| `iam/` | IAM roles and policies | IAM |
| `lambda/` | Serverless function deployment | Lambda |
| `msk/` | Kafka cluster configuration | MSK |
| `opensearch/` | Search engine cluster | OpenSearch |
| `rds/` | Relational database instance | RDS |
| `s3/` | Object storage buckets | S3 |
| `secrets-manager/` | Secret storage and rotation | Secrets Manager |
| `vpc/` | VPC, subnets, NAT gateways | VPC |
| `waf/` | Web application firewall | WAF |

### terraform/environments/

| Environment | Purpose | Files |
|-------------|---------|-------|
| `dev/` | Development environment | providers.tf, variables.tf, main.tf |
| `prod/` | Production environment | providers.tf, variables.tf, main.tf |
| `stage/` | Staging environment | providers.tf, variables.tf, main.tf |

### terraform/backend-init/

Backend initialization configuration for Terraform state management.

---

## .github/workflows/ - CI/CD Pipelines

| Workflow | Purpose | Trigger |
|----------|---------|--------|
| `ci.yaml` | Comprehensive CI pipeline for all services | Push, PR |
| `ci-cd.yaml` | Combined CI/CD pipeline | Push to main |
| `cd-dev.yaml` | Development environment deployment | Push to dev branch |
| `cd-stage.yaml` | Staging environment deployment | Push to stage branch |
| `cd-prod.yaml` | Production environment deployment | Push to prod branch |

---

## k8s/ - Kubernetes Manifests

| Manifest | Purpose |
|----------|--------|
| `deployment.yaml` | Service deployment specs |
| `service.yaml` | K8s service definitions |
| `configmap.yaml` | Configuration maps |
| `external-dns.yaml` | DNS automation |
| `ingress.yaml` | Ingress controller rules |
| `hpa.yaml` | Horizontal Pod Autoscaler |
| `namespace.yaml` | Namespace definitions |
| `rbac.yaml` | Role-based access control |
| `secrets.yaml` | Secret references |

---

## helm/streamplatform/ - Helm Charts

| Chart | Purpose |
|-------|--------|
| `Chart.yaml` | Chart metadata |
| `values.yaml` | Default configuration values |
| `values-dev.yaml` | Development overrides |
| `values-stage.yaml` | Staging overrides |
| `values-prod.yaml` | Production overrides |
| `templates/` | Kubernetes template files |
| `deployment.yaml` | Deployment template |
| `service.yaml` | Service template |
| `ingress.yaml` | Ingress template |
| `configmap.yaml` | ConfigMap template |
| `secrets.yaml` | Secrets template |
| `hpa.yaml` | HPA template |
| `moderation-deployment.yaml` | Content moderation deployment |

---

## monitoring/ - Monitoring Stack

| Component | Purpose |
|-----------|--------|
| `alert-rules.yml` | Prometheus alerting rules |
| `prometheus.yml` | Prometheus configuration |
| `grafana/` | Grafana dashboards and provisioning |

---

## db/migrations/ - Database Migrations

| Migration | Purpose |
|-----------|--------|
| `001_initial_schema.sql` | Initial database schema |
| `002_user_profiles.sql` | User profile tables |
| `003_video_metadata.sql` | Video metadata tables |
| `004_analytics_events.sql` | Analytics event tracking |
| `005_reward_system.sql` | Reward and gamification |
| `006_recommendation_index.sql` | Recommendation indexing |
| `007_search_vectors.sql` | Vector search embeddings |

---

## scripts/ - Automation Scripts

| Script | Purpose |
|--------|--------|
| `deploy-dev.sh` | Development deployment |
| `deploy-stage.sh` | Staging deployment |
| `deploy-prod.sh` | Production deployment |
| `setup-eks.sh` | EKS cluster setup |
| `rotate-secrets.sh` | Secret rotation |
| `health-check.sh` | Service health checks |
| `backup-db.sh` | Database backup |

---

## loadtest/k6/ - Load Testing

| Script | Purpose |
|--------|--------|
| `api-load-test.js` | API performance stress test |
| `streaming-load-test.js` | Streaming load simulation |

---

## Architecture Diagram

```
streamplatform/
├── .github/workflows/     # CI/CD (5 workflows)
├── db/migrations/         # Database migrations
├── helm/streamplatform/   # Helm charts
├── k8s/                   # Kubernetes manifests
├── loadtest/k6/           # Load testing
├── monitoring/            # Prometheus, Grafana
├── scripts/               # Deployment scripts
├── services/              # 10 microservices
│   ├── ai-service/
│   ├── auth-service/
│   ├── computer-vision-service/
│   ├── nlp-service/
│   ├── notification-service/
│   ├── recommendation-service/
│   ├── reward-service/
│   ├── search-service/
│   ├── transcode-service/
│   └── video-service/
├── terraform/
│   ├── backend-init/      # State backend config
│   ├── environments/      # dev, prod, stage
│   └── modules/           # 15 AWS modules
│       ├── cloudfront/
│       ├── cloudwatch/
│       ├── documentdb/
│       ├── ecr/
│       ├── eks/
│       ├── elasticache/
│       ├── iam/
│       ├── lambda/
│       ├── msk/
│       ├── opensearch/
│       ├── rds/
│       ├── s3/
│       ├── secrets-manager/
│       ├── vpc/
│       └── waf/
├── .env.example
├── .gitignore
├── docker-compose.yml
├── docker-compose.test.yml
├── Makefile
├── package.json
└── *.md (13 documentation files)
```

---

## Technology Stack

### Infrastructure
- **Cloud:** AWS (EKS, ECR, RDS, S3, CloudFront, MSK, OpenSearch, ElastiCache)
- **IaC:** Terraform (15 modules across 3 environments)
- **Containerization:** Docker, Docker Compose
- **Orchestration:** Kubernetes (EKS), Helm

### Microservices
- **Runtime:** Python 3.11+
- **Frameworks:** FastAPI, Flask
- **AI/ML:** TensorFlow, PyTorch, Transformers
- **Search:** OpenSearch/Elasticsearch
- **Database:** PostgreSQL, DynamoDB, DocumentDB

### CI/CD & DevOps
- **CI/CD:** GitHub Actions (5 workflows)
- **Monitoring:** Prometheus, Grafana, CloudWatch
- **Load Testing:** K6
- **Secrets:** AWS Secrets Manager

---

## How to Use This Document

### For New Developers
1. Review the **Architecture Diagram** for high-level understanding
2. Check **services/** for microservice code
3. Refer to **terraform/** for infrastructure understanding
4. Use **SETUP_GUIDE.md** for local development setup

### For DevOps Engineers
1. Examine **terraform/modules/** for AWS resource definitions
2. Review **k8s/** and **helm/** for deployment configurations
3. Check **.github/workflows/** for CI/CD pipeline logic
4. Use **scripts/** for deployment automation

### For Contributors
1. Follow the directory structure conventions
2. Add new services under **services/**
3. Add new Terraform modules under **terraform/modules/**
4. Update this file when adding new directories

---
