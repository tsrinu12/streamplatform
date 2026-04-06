# StreamPlatform

> **Enterprise Production-Grade Multi-Environment Microservices Platform for AI-Powered Video Streaming**

[![Status](https://img.shields.io/badge/status-In%20Progress-yellow)](https://github.com/tsrinu12/streamplatform)
[![Commits](https://img.shields.io/github/commit-activity/m/tsrinu12/streamplatform)](https://github.com/tsrinu12/streamplatform/commits/main)
[![Deployments](https://img.shields.io/github/deployments/tsrinu12/streamplatform/development)](https://github.com/tsrinu12/streamplatform/deployments)
[![License](https://img.shields.io/badge/license-Proprietary-blue)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Services](#services)
- [Environments](#environments)
- [Quick Start](#quick-start)
- [Status Definitions](#status-definitions)
- [Current Progress](#current-progress)
- [Documentation Map](#documentation-map)
- [Technology Stack](#technology-stack)
- [CI/CD](#cicd)
- [Monitoring](#monitoring)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

StreamPlatform is an enterprise-grade, cloud-native microservices platform designed for AI-powered video streaming and content delivery. Built with a DevOps-first approach, it combines Kubernetes orchestration, Infrastructure-as-Code (Terraform), GitOps (ArgoCD), and integrated AI algorithms to deliver a scalable, production-ready OTT (Over-The-Top) streaming solution.

The platform supports **multi-environment deployments** (development, staging, production) with fully automated CI/CD pipelines, comprehensive monitoring, and load testing capabilities.

---

## Features

- **Multi-Environment Support**: Dev, Stage, and Production environments with isolated configurations
- **Microservices Architecture**: 10+ containerized services with clear separation of concerns
- **AI-Powered Streaming**: Integrated computer vision, NLP, and recommendation engines
- **Infrastructure-as-Code**: Full AWS provisioning via Terraform modules
- **GitOps Deployment**: ArgoCD-based continuous deployment to Kubernetes
- **Comprehensive Monitoring**: Prometheus, Grafana, and Alertmanager stack
- **Load Testing**: K6-based performance, stress, and smoke testing
- **Database Migrations**: PostgreSQL schema with versioned migrations
- **Helm Charts**: Kubernetes packaging with environment-specific values
- **CI/CD Automation**: GitHub Actions workflows for all environments

---

## Architecture

```text
                                    ┌─────────────────────────────────────────────┐
                                    │              AWS Cloud (EKS)                │
                                    │  ┌─────────────────────────────────────┐    │
                                    │  │          Kubernetes Cluster         │    │
                                    │  │  ┌──────────────────────────────┐   │    │
                                    │  │  │     Helm Chart (streamplatform) │   │    │
                                    │  │  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │   │    │
                                    │  │  │  │Auth│ │Video│ │ AI │ │NLP │  │   │    │
                                    │  │  │  └────┘ └────┘ └────┘ └────┘  │   │    │
                                    │  │  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │   │    │
                                    │  │  │  │CV  │ │Rec │ │Rew │ │Trns│  │   │    │
                                    │  │  │  └────┘ └────┘ └────┘ └────┘  │   │    │
                                    │  │  └──────────────────────────────┘   │    │
                                    │  └─────────────────────────────────────┘    │
                                    │         ┌─────────┐ ┌─────────┐            │
                                    │         │   RDS   │ │ DocumentDB│           │
                                    │         │(Postgres)│ │ (MongoDB)│           │
                                    │         └─────────┘ └─────────┘            │
                                    │         ┌─────────┐ ┌─────────┐            │
                                    │         │ElastiCache│ │   MSK   │           │
                                    │         │  (Redis)  │ │ (Kafka) │           │
                                    │         └─────────┘ └─────────┘            │
                                    └─────────────────────────────────────────────┘
                                            │
                    ┌───────────────────────┴───────────────────────┐
                    │                                               │
            ┌───────┴───────┐                               ┌───────┴───────┐
            │  CI/CD (GitHub│                               │  Monitoring   │
            │    Actions)   │                               │(Prometheus/   │
            │  ┌─────────┐  │                               │ Grafana/      │
            │  │ ArgoCD  │  │                               │ Alertmanager) │
            │  └─────────┘  │                               │               │
            └───────────────┘                               └───────────────┘
```

---

## Project Structure

| Directory | Description |
|-----------|-------------|
| `.github/workflows/` | CI/CD pipelines: ci.yaml, ci-cd.yaml, cd-dev.yaml, cd-stage.yaml, cd-prod.yaml |
| `db/migrations/` | PostgreSQL schema migrations (`001_initial_schema.sql`) |
| `helm/streamplatform/` | Helm chart with Chart.yaml, values.yaml, and env-specific values (dev/stage/prod) |
| `k8s/` | Kubernetes manifests: argocd (GitOps), cluster-addons (External DNS, etc.) |
| `loadtest/k6/` | K6 load testing scripts: load.js, smoke.js, stress.js |
| `monitoring/` | Observability stack: alertmanager, grafana/dashboards, prometheus |
| `scripts/` | Deployment automation: setup.sh, deploy-prod.sh |
| `services/` | Microservices (10 services - see [Services](#services)) |
| `terraform/` | Infrastructure-as-Code: backend-init, environments (dev/stage/prod), modules (15 AWS services) |

---

## Services

StreamPlatform consists of **10 microservices**, each containerized and independently deployable:

| # | Service | Directory | Status |
|---|---------|-----------|--------|
| 1 | **Auth Service** | `services/auth-service/` | Implemented |
| 2 | **AI Service** | `services/ai-service/` | Implemented |
| 3 | **Computer Vision Service** | `services/computer-vision-service/` | Implemented |
| 4 | **NLP Service** | `services/nlp-service/` | Implemented |
| 5 | **Notification Service** | `services/notification-service/` | Implemented |
| 6 | **Recommendation Service** | `services/recommendation-service/` | Implemented |
| 7 | **Reward Service** | `services/reward-service/` | Implemented |
| 8 | **Search Service** | `services/search-service/` | Implemented |
| 9 | **Transcode Service** | `services/transcode-service/` | Implemented |
| 10 | **Video Service** | `services/video-service/` | Implemented |

Each service follows a consistent structure with Dockerfile, source code, configuration, and deployment manifests.

---

## Environments

StreamPlatform supports **three isolated environments**, each with its own Terraform configuration:

| Environment | Directory | Purpose |
|-------------|-----------|----------|
| **Development** | `terraform/environments/dev/` | Developer testing and integration |
| **Staging** | `terraform/environments/stage/` | Pre-production validation |
| **Production** | `terraform/environments/prod/` | Live customer-facing deployment |

Each environment uses shared Terraform modules from `terraform/modules/` to ensure consistency while allowing environment-specific customization via `terraform.tfvars`.

---

## Quick Start

### Prerequisites

- **Docker** and **Docker Compose**
- **kubectl** (Kubernetes CLI)
- **Helm** 3.x
- **Terraform** 1.6+
- **AWS CLI** configured with appropriate credentials
- **Node.js** 20.x (for local development)
- **Python** 3.11+ (for AI services)

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/tsrinu12/streamplatform.git
cd streamplatform

# Copy environment variables template
cp .env.example .env

# Start local services with Docker Compose
make up

# Or manually:
docker-compose -f docker-compose.dev.yaml up -d
```

### Deploy to Kubernetes

```bash
# Create a local Kubernetes cluster (using kind or minikube)
kind create cluster --name streamplatform

# Deploy using Helm
helm upgrade --install streamplatform ./helm/streamplatform -f ./helm/streamplatform/values-dev.yaml

# Or deploy to a specific environment
helm upgrade --install streamplatform ./helm/streamplatform -f ./helm/streamplatform/values-prod.yaml
```

### Infrastructure Provisioning (AWS)

```bash
cd terraform/backend-init
terraform init
terraform apply

cd ../environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Run Load Tests

```bash
# Smoke test (health check)
k6 run loadtest/k6/smoke.js

# Load test
k6 run loadtest/k6/load.js

# Stress test
k6 run loadtest/k6/stress.js
```

---

## Status Definitions

All documentation uses standardized status labels for consistency:

| Status | Meaning |
|--------|----------|
| **Implemented** | Code, configuration, and deployment artifacts exist in the repository and are functional. |
| **Partially Implemented** | Scaffolding exists but requires additional integration, validation, or production hardening. |
| **Planned** | Documented intent only; no meaningful implementation in the repository. |
| **Deprecated** | Retained for historical reference; not part of the current development path. |

---

## Current Progress

| Component | Status | Details |
|-----------|--------|----------|
| **Terraform Modules** | Implemented | 15 AWS modules: VPC, EKS, RDS, DocumentDB, ElastiCache, MSK, S3, CloudFront, OpenSearch, WAF, Secrets Manager, CloudWatch, ECR, IAM, Lambda |
| **Terraform Environments** | Implemented | Dev, Stage, Prod configurations |
| **Kubernetes Manifests** | Implemented | ArgoCD GitOps, Cluster Addons |
| **Helm Chart** | Implemented | StreamPlatform chart with multi-environment values |
| **CI/CD Pipelines** | Implemented | CI, CI-CD, CD-Dev, CD-Stage, CD-Prod workflows |
| **Microservices** | Implemented | 10 services with Docker configurations |
| **Monitoring Stack** | Implemented | Prometheus, Grafana, Alertmanager |
| **Load Testing** | Implemented | K6 stress, load, and smoke tests |
| **Database Migrations** | Implemented | PostgreSQL initial schema |
| **Deployment Scripts** | Implemented | setup.sh, deploy-prod.sh |
| **Documentation** | In Progress | 13 markdown files covering all aspects |

**Total Commits**: 144+
**Last Updated**: April 6, 2026

---

## Documentation Map

| File | Purpose |
|------|----------|
| [`README.md`](README.md) | This file - Main entry point and overview |
| [`MICROSERVICES_AUDIT.md`](MICROSERVICES_AUDIT.md) | Detailed audit of each microservice and AI algorithm |
| [`PROJECT_COMPLETION_STATUS.md`](PROJECT_COMPLETION_STATUS.md) | Overall project completion dashboard and roadmap |
| [`PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md) | Complete directory structure and file organization |
| [`AI_ALGORITHMS_REGISTRY.md`](AI_ALGORITHMS_REGISTRY.md) | Catalog of AI algorithms and model integrations |
| [`AWS_CLOUD_DEPLOYMENT.md`](AWS_CLOUD_DEPLOYMENT.md) | AWS-specific deployment guide |
| [`MULTI_ENVIRONMENT_READINESS.md`](MULTI_ENVIRONMENT_READINESS.md) | Environment readiness assessment |
| [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) | Technical implementation details |
| [`SETUP_GUIDE.md`](SETUP_GUIDE.md) | Local and cloud setup instructions |
| [`FILE_INVENTORY.md`](FILE_INVENTORY.md) | Complete file inventory |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution guidelines |

---

## Technology Stack

### Infrastructure
- **Cloud Provider**: AWS
- **Container Orchestration**: Kubernetes 1.29+ (EKS)
- **Infrastructure-as-Code**: Terraform 1.6+
- **Package Management**: Helm 3+
- **GitOps**: ArgoCD

### Backend Services
- **Languages**: Python 3.11+, Go 1.21+, Node.js 20.x
- **Databases**: PostgreSQL 16+, MongoDB 7+, Redis 7+
- **Messaging**: Apache Kafka 3.6+ (MSK)
- **Task Queue**: Celery

### Frontend (Planned)
- **Framework**: Next.js 14+
- **UI Library**: React 18+
- **Styling**: Tailwind CSS
- **State Management**: Zustand

### AI & ML
- **Computer Vision**: YOLOv8, CLIP
- **NLP**: Whisper, BERT/RoBERTa, BART/T5
- **Video Understanding**: V-JEPA
- **Optimization**: TensorRT, Quantization (INT8/FP16)

### Monitoring & Observability
- **Metrics**: Prometheus
- **Visualization**: Grafana
- **Alerting**: Alertmanager
- **Load Testing**: K6

### CI/CD
- **Platform**: GitHub Actions
- **Deployment**: ArgoCD (GitOps)

---

## CI/CD

StreamPlatform uses **GitHub Actions** for continuous integration and deployment:

| Workflow | Trigger | Purpose |
|----------|---------|----------|
| `ci.yaml` | Push to any branch | Run linters, tests, and builds |
| `ci-cd.yaml` | Push to main | Full CI/CD pipeline |
| `cd-dev.yaml` | Push to main | Deploy to development environment |
| `cd-stage.yaml` | Push to main | Deploy to staging environment |
| `cd-prod.yaml` | Tag push | Deploy to production environment |

ArgoCD watches the repository and automatically syncs Kubernetes manifests to the cluster, ensuring drift-free deployments.

---

## Monitoring

The platform includes a comprehensive observability stack:

- **Prometheus**: Metrics collection and alerting rules
- **Grafana**: Pre-configured dashboards for platform metrics
- **Alertmanager**: Alert routing and notification

```bash
# Access Grafana dashboard
kubectl port-forward svc/grafana 3000:80 -n monitoring

# Access Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

---

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct, development workflow, and how to submit pull requests.

### Quick Contribution Flow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Run tests and linting
5. Commit with conventional commits
6. Push and open a Pull Request

---

## License

Proprietary. All rights reserved.

---

**Built with by the StreamPlatform Team** | **Last Updated: April 6, 2026**
