# StreamPlatform - Setup Guide

Complete setup instructions for local development, testing, and deployment of the StreamPlatform microservices platform.

Last Updated: April 6, 2026 | Repository: tsrinu12/streamplatform | Total Commits: 148+

---

## Prerequisites

Before setting up StreamPlatform, ensure you have the following installed:

| Tool | Version | Purpose |
|------|---------|--------|
| Git | 2.35+ | Source control |
| Docker | 24.0+ | Containerization |
| Docker Compose | 2.20+ | Local multi-container setup |
| Python | 3.11+ | Microservices runtime |
| Node.js | 18+ | Frontend build tools |
| Terraform | 1.6+ | Infrastructure provisioning |
| kubectl | 1.28+ | Kubernetes CLI |
| Helm | 3.13+ | Kubernetes package manager |
| AWS CLI | 2.15+ | AWS cloud management |
| Make | 4.0+ | Build automation |

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/tsrinu12/streamplatform.git
cd streamplatform
```

### 2. Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your local configuration
```

### 3. Start Local Development Environment

```bash
make up
# Or manually:
docker-compose up -d
```

### 4. Verify Services

```bash
make health
# Check individual services:
docker-compose ps
```

---

## Local Development Setup

### Option A: Docker Compose (Recommended)

Start all services with Docker Compose:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Option B: Individual Services

Run services individually for debugging:

```bash
# Start a specific service
docker-compose up -d auth-service

# Run in foreground for debugging
docker-compose up ai-service
```

### Option C: Local Python Development

For direct Python development without Docker:

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows

# Install service dependencies
cd services/ai-service
pip install -r requirements.txt

# Run the service
python main.py
```

---

## Service Configuration

### Microservices (services/)

Each microservice is self-contained with its own Dockerfile and requirements:

| Service | Port | Docker Command |
|---------|------|---------------|
| ai-service | 8001 | `docker-compose up ai-service` |
| auth-service | 8002 | `docker-compose up auth-service` |
| computer-vision-service | 8003 | `docker-compose up computer-vision-service` |
| nlp-service | 8004 | `docker-compose up nlp-service` |
| notification-service | 8005 | `docker-compose up notification-service` |
| recommendation-service | 8006 | `docker-compose up recommendation-service` |
| reward-service | 8007 | `docker-compose up reward-service` |
| search-service | 8008 | `docker-compose up search-service` |
| transcode-service | 8009 | `docker-compose up transcode-service` |
| video-service | 8010 | `docker-compose up video-service` |

### Environment Variables

Copy and configure `.env.example`:

```bash
cp .env.example .env
```

Key variables to configure:

| Variable | Description | Example |
|----------|-------------|--------|
| `AWS_REGION` | AWS region for cloud services | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | AWS access key | (from AWS IAM) |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | (from AWS IAM) |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@localhost:5432/streamplatform` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `JWT_SECRET` | JWT signing secret | `your-secret-key` |
| `OPENAI_API_KEY` | OpenAI API key (for NLP) | (from OpenAI) |
| `SMTP_HOST` | Email server host | `smtp.gmail.com` |
| `SMTP_PORT` | Email server port | `587` |

---

## Database Setup

### PostgreSQL (Local)

```bash
# Start PostgreSQL via Docker Compose
docker-compose up -d postgres

# Run migrations
psql -h localhost -U postgres -d streamplatform -f db/migrations/001_initial_schema.sql
psql -h localhost -U postgres -d streamplatform -f db/migrations/002_user_profiles.sql
psql -h localhost -U postgres -d streamplatform -f db/migrations/003_video_metadata.sql
```

### Check Migrations

```bash
# List all migrations
ls db/migrations/

# Verify schema
psql -h localhost -U postgres -d streamplatform -c "\dt"
```

---

## Infrastructure Setup (Terraform)

### Initialize Terraform

```bash
cd terraform

# Initialize backend
terraform init -backend-config=backend-init/backend.hcl

# Initialize modules for dev environment
cd environments/dev
terraform init
```

### Plan Infrastructure Changes

```bash
# Review planned changes
terraform plan

# Apply changes
terraform apply -auto-approve
```

### Deploy to Different Environments

```bash
# Development
cd terraform/environments/dev && terraform apply

# Staging
cd terraform/environments/stage && terraform apply

# Production
cd terraform/environments/prod && terraform apply
```

---

## Kubernetes Deployment

### Local Kubernetes (kind/minikube)

```bash
# Create a local cluster with kind
kind create cluster --name streamplatform

# Apply Kubernetes manifests
kubectl apply -f k8s/

# Install Helm charts
helm install streamplatform ./helm/streamplatform --values ./helm/streamplatform/values-dev.yaml
```

### AWS EKS

```bash
# Update kubeconfig for EKS cluster
aws eks update-kubeconfig --name streamplatform-eks --region us-east-1

# Verify cluster connection
kubectl get nodes

# Deploy application
kubectl apply -f k8s/
```

---

## CI/CD Pipeline

### GitHub Actions Workflows

| Workflow | File | Description |
|----------|------|-------------|
| CI Pipeline | `ci.yaml` | Lint, test, build on every push |
| CI/CD Combined | `ci-cd.yaml` | Full pipeline on main branch |
| Dev Deployment | `cd-dev.yaml` | Auto-deploy to dev environment |
| Stage Deployment | `cd-stage.yaml` | Deploy to staging |
| Prod Deployment | `cd-prod.yaml` | Deploy to production (manual approval) |

### Trigger a Manual Deployment

```bash
# Push to trigger dev deployment
git push origin feature-branch

# Create PR for staging
git push origin stage

# Merge to main for production
git push origin main
```

---

## Testing

### Run Tests Locally

```bash
# Run all tests with Docker Compose
docker-compose -f docker-compose.test.yml up

# Run tests for a specific service
cd services/ai-service
pytest tests/

# Run integration tests
docker-compose -f docker-compose.test.yml up integration-tests
```

### Load Testing with K6

```bash
# Run API load test
cd loadtest/k6
k6 run api-load-test.js

# Run streaming load test
k6 run streaming-load-test.js
```

---

## Monitoring

### Access Monitoring Dashboards

| Service | URL | Description |
|---------|-----|-------------|
| Prometheus | `http://localhost:9090` | Metrics and alerts |
| Grafana | `http://localhost:3000` | Visualization dashboards |
| AlertManager | `http://localhost:9093` | Alert management |

### View Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f ai-service

# Kubernetes pods
kubectl logs -f deployment/ai-service
```

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start all services with Docker Compose |
| `make down` | Stop all services |
| `make logs` | View logs from all services |
| `make health` | Run health checks on all services |
| `make test` | Run all tests |
| `make lint` | Run linting on all code |
| `make build` | Build all Docker images |
| `make deploy-dev` | Deploy to development environment |
| `make deploy-stage` | Deploy to staging environment |
| `make deploy-prod` | Deploy to production environment |
| `make terraform-init` | Initialize Terraform |
| `make terraform-plan` | Plan Terraform changes |
| `make terraform-apply` | Apply Terraform changes |
| `make k8s-apply` | Apply Kubernetes manifests |
| `make helm-install` | Install Helm charts |
| `make clean` | Remove all containers and volumes |

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|--------|
| Port already in use | Change port in docker-compose.yml or stop conflicting service |
| Docker build fails | Clear build cache: `docker builder prune` |
| Terraform state locked | Run `terraform force-unlock <LOCK_ID>` |
| Kubernetes pods not ready | Check `kubectl describe pod <pod-name>` |
| Database connection failed | Verify DATABASE_URL and PostgreSQL is running |
| Service health check fails | Check service logs: `docker-compose logs <service>` |

### Getting Help

- Check `README.md` for project overview
- Review `PROJECT_STRUCTURE.md` for directory layout
- See `MICROSERVICES_AUDIT.md` for service statuses
- Consult `CONTRIBUTING.md` for contribution guidelines
- Open an issue on GitHub for bugs or feature requests

---

## Next Steps

1. Complete local setup with `make up`
2. Verify all services are healthy with `make health`
3. Run tests with `make test`
4. Explore the monitoring dashboard at `http://localhost:9090`
5. Start developing features or contributing to the project

---

**Created:** 2026-03-07 | **Last Updated:** 2026-04-06 | **Version:** 2.0.0 | **Status:** Production Ready
