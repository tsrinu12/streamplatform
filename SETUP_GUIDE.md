# StreamPlatform Complete Setup Guide

## Quick Start - Automated Setup

To populate this repository with all production-grade files and structures, follow these steps:

### Option 1: Using the Automated Script (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/tsrinu12/streamplatform.git
cd streamplatform

# 2. Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/tsrinu12/streamplatform/main/scripts/setup.sh | bash

# 3. Verify the structure
ls -la

# 4. Commit all files
git add .
git commit -m "feat: Complete StreamPlatform enterprise project structure"
git push
```

### What Gets Created

✅ **Root Configuration Files** (15+ files)
- .gitignore, .editorconfig, .env.example
- Makefile, CHANGELOG.md, CONTRIBUTING.md, LICENSE
- docker-compose.yaml, docker-compose.dev.yaml, docker-compose.test.yaml, docker-compose.monitoring.yaml

✅ **GitHub Workflows** (8 CI/CD files)
- ci.yaml, cd-dev.yaml, cd-stage.yaml, cd-prod.yaml
- rollback.yaml, terraform-plan.yaml, terraform-apply.yaml, nightly-security.yaml

✅ **Terraform Infrastructure** (40+ files)
- Backend initialization
- Modules: VPC, EKS, RDS, DocumentDB, ElastiCache, MSK, S3, CloudFront, ECR, OpenSearch, WAF, Secrets Manager, CloudWatch
- Environment configs: dev, stage, prod

✅ **Microservices** (5 services with complete structure)
- Auth Service (TypeScript/Node.js)
- Video Service (Go)
- AI Service (Python)
- Reward Service (Python)  
- Transcode Worker (Python/Celery)

✅ **Frontend** (Next.js Application)
- Complete app structure with routing
- Components, hooks, stores, types
- Authentication, video player, rewards system

✅ **Database** (Migrations & Schemas)
- PostgreSQL migrations (4 files)
- MongoDB initialization
- Database seeds for dev/stage

✅ **Kubernetes & Helm**
- Helm charts for StreamPlatform
- ArgoCD configurations
- Cluster addons (AWS Load Balancer, External DNS, etc)
- Observability stack setup

✅ **Monitoring & Observability**
- Prometheus configuration
- Grafana dashboards
- AlertManager setup
- Distributed tracing (Tempo)

✅ **Documentation**
- Architecture documentation
- API reference
- Deployment guide
- Runbooks & disaster recovery

✅ **Load Testing**
- K6 performance test scripts
- Smoke, load, stress, spike tests

## Project Structure

```
streamplatform/
├── .github/
│   ├── workflows/          # CI/CD pipelines
│   ├── CODEOWNERS
│   └── pull_request_template.md
├── terraform/
│   ├── backend-init/       # S3 + DynamoDB setup
│   ├── modules/            # Reusable infrastructure modules
│   └── environments/       # dev, stage, prod configs
├── helm/
│   └── streamplatform/     # Kubernetes Helm charts
├── k8s/
│   ├── argocd/            # GitOps deployments
│   ├── cluster-addons/    # AWS Load Balancer, External DNS, etc
│   └── observability/     # Prometheus, Grafana, Loki, Tempo
├── services/
│   ├── auth-service/      # Authentication & authorization
│   ├── video-service/     # Video upload & streaming
│   ├── ai-service/        # ML & recommendations
│   ├── reward-service/    # Points & gamification
│   ├── transcode-worker/  # Video transcoding
│   └── notification-service/ # Notifications
├── frontend/
│   └── web-app/          # Next.js web application
├── db/
│   ├── migrations/        # SQL migrations
│   ├── seeds/            # Database seeds
│   └── mongo/            # MongoDB initialization
├── monitoring/
│   ├── prometheus/       # Metrics collection
│   ├── grafana/          # Visualization
│   └── alertmanager/     # Alerting
├── loadtest/
│   └── k6/              # Performance testing
├── docs/
│   ├── architecture/
│   ├── api-reference.md
│   ├── deployment-guide.md
│   ├── runbook.md
│   └── adr/             # Architecture Decision Records
├── scripts/
│   ├── setup.sh         # Main setup script
│   ├── deploy.sh        # Deployment script
│   └── ...              # Other utility scripts
└── nginx/              # API Gateway configs

```

## Key Files Created

### Root Configuration
- `.env.example` - Environment variables template
- `.gitignore` - Git ignore patterns
- `.editorconfig` - Editor configuration
- `Makefile` - Build & deployment commands
- `docker-compose.yaml` - Full stack docker setup
- `docker-compose.dev.yaml` - Development overrides
- `docker-compose.test.yaml` - Testing environment
- `docker-compose.monitoring.yaml` - Monitoring stack

### GitHub Workflows (CI/CD)
- `.github/workflows/ci.yaml` - Code quality & testing
- `.github/workflows/cd-dev.yaml` - Deploy to dev
- `.github/workflows/cd-stage.yaml` - Deploy to staging
- `.github/workflows/cd-prod.yaml` - Deploy to production
- `.github/workflows/rollback.yaml` - Rollback procedures
- `.github/workflows/terraform-plan.yaml` - Plan infrastructure changes
- `.github/workflows/terraform-apply.yaml` - Apply infrastructure changes
- `.github/workflows/nightly-security.yaml` - Security scans

### Services

Each service includes:
- `Dockerfile` - Production image
- `Dockerfile.dev` - Development image
- Complete source structure
- Tests
- Configuration

### Database
- `db/migrations/001_initial_schema.sql` - Users, sessions, OTP
- `db/migrations/002_reward_tables.sql` - Reward system
- `db/migrations/003_indexes.sql` - Performance indexes
- `db/migrations/004_functions.sql` - PL/pgSQL functions
- `db/mongo/init.js` - MongoDB collections & indexes

## Technologies Included

- **Backend Services**: TypeScript, Go, Python
- **Frontend**: Next.js, React, TailwindCSS
- **Infrastructure**: Terraform, AWS
- **Container**: Docker, Docker Compose
- **Orchestration**: Kubernetes, Helm, ArgoCD
- **Databases**: PostgreSQL, MongoDB, Redis, ElastiCache
- **Messaging**: Kafka, AWS SNS/SQS
- **Search**: Elasticsearch, Qdrant
- **Monitoring**: Prometheus, Grafana, Loki, Tempo
- **CI/CD**: GitHub Actions
- **Load Testing**: K6

## Development Workflow

1. **Local Development**
   ```bash
   make up          # Start all services
   make logs        # View logs
   make test        # Run tests
   make lint        # Lint code
   ```

2. **Deploy to Dev**
   ```bash
   git push origin feature-branch
   # GitHub Actions automatically deploys to dev environment
   ```

3. **Deploy to Stage/Prod**
   - Create Pull Request
   - Get review & approval
   - Merge to main branch
   - GitHub Actions deploys to staging
   - Manual approval for production

## Configuration

### Environment Variables
Update `.env` with your values for each environment:
- AWS credentials
- Database passwords
- API keys (Google, OpenAI, Razorpay, etc)
- Service ports

### Terraform Variables
Update `terraform/environments/{env}/terraform.tfvars` for each environment

### Kubernetes Secrets
Create secrets in `k8s/secrets/` for sensitive data

## Monitoring & Observability

- **Prometheus**: `http://localhost:9090` (localhost:9090 when running locally)
- **Grafana**: `http://localhost:3001` (dashboards)
- **Jaeger Traces**: Distributed tracing for requests
- **Loki**: Log aggregation

## Support & Documentation

- Architecture: See `docs/architecture/`
- API Reference: See `docs/api-reference.md`
- Deployment: See `docs/deployment-guide.md`
- Runbooks: See `docs/runbook.md`
- ADRs: See `docs/adr/`

## Next Steps

1. ✅ Run the automated setup script
2. ✅ Review the created structure
3. ✅ Update `.env` with your configuration
4. ✅ Configure Terraform variables for your AWS account
5. ✅ Update service configurations as needed
6. ✅ Start developing!

---

**Created**: 2026-03-07
**Version**: 1.0.0
**Status**: Production Ready
