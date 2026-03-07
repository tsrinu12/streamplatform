# StreamPlatform - Tiered File Structure Implementation

This document provides a template and structure for all tiered files in the StreamPlatform project.

## Tier 1: Infrastructure as Code (Terraform)

### Modules Structure
Every module in `terraform/modules/` (EKS, RDS, DocumentDB, ElastiCache, MSK, S3, CloudFront, ECR, OpenSearch, WAF, Secrets Manager, CloudWatch) must contain:
- `main.tf`: Core resource definitions
- `variables.tf`: Input parameters
- `outputs.tf`: Exported attributes

### Environment Structure
Every environment in `terraform/environments/` (dev, stage, prod) must contain:
- `main.tf`: Module instantiations
- `terraform.tfvars`: Environment-specific values
- `outputs.tf`: Environment-specific outputs
- `backend.tf`: Remote state configuration

## Tier 2: Kubernetes & Helm

### Helm Chart (`helm/streamplatform/`)
- `Chart.yaml`: Metadata
- `values.yaml`: Default values
- `values-dev.yaml`, `values-stage.yaml`, `values-prod.yaml`: Environment overrides
- `templates/`: K8s manifests (auth, video, ai, reward, transcode, frontend)

### Kubernetes Manifests (`k8s/`)
- `argocd/`: Application definitions for GitOps
- `cluster-addons/`: Infrastructure components (ingress, dns, certs)
- `observability/`: Monitoring stack manifests

## Tier 3: Microservices Implementation

Each service in `services/` (auth, video, ai, reward, transcode) must follow this structure:
- `Dockerfile`, `Dockerfile.dev`
- `src/` or `internal/`: Application logic
- `tests/`: Unit and integration tests
- Language-specific configs (`package.json`, `go.mod`, `requirements.txt`)

## Tier 4: Frontend Application

`frontend/web-app/` follows Next.js 14 conventions:
- `app/`: Routing and pages
- `components/`: UI components (UI, layout, features)
- `lib/`, `hooks/`, `store/`: Utility logic
- `public/`: Static assets

## Tier 5: Observability & Operations

- `monitoring/`: Prometheus, Grafana, Alertmanager configurations
- `loadtest/`: K6 performance test scripts
- `docs/`: ADRs, API Reference, Runbooks

## Tier 6: Additional Infrastructure

- `.github/workflows/`: Complete CI/CD suite (dev/stage/prod/rollback)
- `nginx/`: Multi-environment proxy configs
- `scripts/`: Production-grade utility scripts

---
*Note: This file serves as a master template for the 250+ files being added across these tiers.*
