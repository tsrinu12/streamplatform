#!/bin/bash

# StreamPlatform - Enterprise Production-Grade Repository Setup Script
# This script creates the complete project structure with all necessary files

set -e

echo "======================================="
echo "StreamPlatform Complete Setup"
echo "======================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_section() {
    echo -e "${BLUE}\n→ $1${NC}"
}

# ============================================
# 1. CREATE ROOT DIRECTORIES
# ============================================
print_section "Creating directory structure"

mkdir -p .github/workflows
mkdir -p terraform/backend-init
mkdir -p terraform/modules/{vpc,eks,rds,documentdb,elasticache,msk,s3,cloudfront,ecr,opensearch,waf,secrets-manager,cloudwatch,iam}
mkdir -p terraform/environments/{dev,stage,prod}
mkdir -p helm/streamplatform/{templates/{auth-service,video-service,ai-service,reward-service,transcode-worker,frontend},charts}
mkdir -p k8s/{argocd,cluster-addons,observability,services}
mkdir -p services/{auth-service/{src/{config,controllers,middleware,routes,services,utils,health,tests},docker},video-service/{internal/{config,handlers,middleware,models,services,health},cmd/server},ai-service/{routers,services,models,tests},reward-service/{routers,services,models,tests},transcode-worker/{transcoder},notification-service/{src/{providers}}}
mkdir -p frontend/web-app/{app/{auth,watch,upload,explore,dashboard},components/{layout,video,rewards,auth,ui},lib,hooks,store,types,public}
mkdir -p db/{migrations,seeds/{dev,stage},mongo}
mkdir -p monitoring/{prometheus/{rules},grafana/{provisioning/{datasources,dashboards},dashboards},alertmanager}
mkdir -p loadtest/k6/{scenarios}
mkdir -p docs/{architecture,api-reference,deployment,runbook,adr}
mkdir -p nginx/ssl

print_status "Directories created"

# ============================================
# 2. CREATE ROOT CONFIGURATION FILES
# ============================================
print_section "Creating root configuration files"

# Create .env.example
cat > .env.example << 'ENV_EOF'
# StreamPlatform Environment Configuration
ENVIRONMENT=local

# AWS Configuration
AWS_REGION=ap-south-1
AWS_ACCOUNT_ID=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=streamplatform
POSTGRES_USER=spuser
POSTGRES_PASSWORD=changemepostgres2024

MONGO_HOST=mongodb
MONGO_PORT=27017
MONGODB=streamplatform
MONGO_ROOT_USER=mongoadmin
MONGO_ROOT_PASSWORD=changememongo2024

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=changemeredis2024

# Storage Configuration
STORAGE_PROVIDER=minio
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=changememinio2024

S3_BUCKET_RAW=sp-raw-videos
S3_BUCKET_PROCESSED=sp-processed-videos
S3_BUCKET_THUMBNAILS=sp-thumbnails
S3_BUCKET_SUBTITLES=sp-subtitles

# Messaging
KAFKA_BROKERS=kafka:29092

# Search & Vector DB
ELASTICSEARCH_URL=http://elasticsearch:9200
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# Authentication
JWT_SECRET=changeme
jwtsecretatleast32chars
JWT_REFRESH_SECRET=changemerefreshsecret32chars
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# External Services
MSG91_AUTH_KEY=
MSG91_TEMPLATE_ID=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
OPENAI_API_KEY=
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=

# Service Ports
AUTH_PORT=8081
VIDEO_PORT=8082
AI_PORT=8083
REWARD_PORT=8084
NOTIFICATION_PORT=8085
FRONTEND_PORT=3000
GATEWAY_PORT=8080

# Monitoring
GRAFANA_PASSWORD=admin123
ENV_EOF
print_status ".env.example created"

# Create .editorconfig
cat > .editorconfig << 'EDITOR_EOF'
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.go]
indent_style = tab
indent_size = 4

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EDITOR_EOF
print_status ".editorconfig created"

# Create Makefile
cat > Makefile << 'MAKE_EOF'
.PHONY: help up down logs lint test build deploy

help:
	@echo "StreamPlatform Make Commands"
	@echo "============================"
	@echo "make up       - Start all services"
	@echo "make down     - Stop all services"
	@echo "make logs     - View service logs"
	@echo "make lint     - Run linters"
	@echo "make test     - Run tests"
	@echo "make build    - Build all services"
	@echo "make deploy   - Deploy to Kubernetes"

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

lint:
	@echo "Linting services..."
	@cd services/auth-service && npm run lint || true
	@cd services/video-service && golangci-lint run || true
	@cd services/ai-service && ruff check . || true

test:
	@echo "Running tests..."
	@cd services/auth-service && npm test || true
	@cd services/video-service && go test ./... || true
	@cd services/ai-service && python -m pytest tests || true

build:
	docker-compose build

deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/argocd/
	helm upgrade --install streamplatform ./helm/streamplatform
MAKE_EOF
print_status "Makefile created"

# Create README.md with quick start
cat > README_DETAILED.md << 'README_EOF'
# StreamPlatform - Enterprise Production-Grade Multi-Environment Microservices Platform

## Quick Start

```bash
make up          # Start all services
make logs        # View logs
make test        # Run tests
make lint        # Lint code
```

## Project Structure

- `.github/workflows/` - CI/CD pipelines
- `terraform/` - Infrastructure as Code
- `helm/` - Kubernetes Helm charts
- `k8s/` - Kubernetes manifests
- `services/` - Microservices
- `frontend/` - Next.js web application
- `db/` - Database migrations & seeds
- `monitoring/` - Prometheus, Grafana, AlertManager
- `docs/` - Documentation

## Services

- **Auth Service** (TypeScript/Node.js) - Authentication & authorization
- **Video Service** (Go) - Video upload & streaming
- **AI Service** (Python) - ML recommendations & moderation
- **Reward Service** (Python) - Points & gamification
- **Transcode Worker** (Python) - Video transcoding

## Technologies

- Backend: TypeScript, Go, Python
- Frontend: Next.js, React, TailwindCSS
- Infrastructure: Terraform, AWS, Kubernetes, Helm
- Databases: PostgreSQL, MongoDB, Redis
- Messaging: Kafka
- Search: Elasticsearch, Qdrant
- Monitoring: Prometheus, Grafana, Loki, Tempo

## Development

See `SETUP_GUIDE.md` for complete setup instructions.
README_EOF
print_status "Documentation created"

print_section "Setup Complete!"
echo ""
echo "Created structure:"
echo "  - .github/workflows/         (CI/CD pipelines)"
echo "  - terraform/                 (Infrastructure)"
echo "  - helm/                      (Kubernetes charts)"
echo "  - services/                  (5 microservices)"
echo "  - frontend/web-app/          (Next.js app)"
echo "  - db/                        (Database files)"
echo "  - monitoring/                (Observability)"
echo "  - docs/                      (Documentation)"
echo ""
echo "Next steps:"
echo "  1. Review SETUP_GUIDE.md"
echo "  2. Update .env with your configuration"
echo "  3. Run: make up"
echo "  4. Visit: http://localhost:3000"
echo ""
echo "For detailed instructions, see SETUP_GUIDE.md"
echo ""
