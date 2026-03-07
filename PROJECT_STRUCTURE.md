# StreamPlatform Project Structure

## Overview
This document provides a comprehensive overview of the StreamPlatform repository structure. The project uses a monorepo architecture with separate frontend, backend services, and infrastructure-as-code components.

## Directory Structure

### Root Level Files (Completed)
- `.gitignore` - Git ignore rules
- `README.md` - Project overview and getting started guide
- `SETUP_GUIDE.md` - Comprehensive setup instructions
- `Makefile` - Development commands and shortcuts
- `package.json` - Root package configuration with npm workspaces
- `docker-compose.yml` - Local development services
- `.env.example` - Environment variables template
- `PROJECT_STRUCTURE.md` - This file

### Root Level Directories (To Be Created)

#### `/frontend`
Next.js/React web application
- `package.json` - Frontend dependencies
- `tsconfig.json` - TypeScript configuration
- `next.config.js` - Next.js configuration
- `.eslintrc.json` - ESLint configuration
- `.prettierrc` - Code formatting configuration
- `public/` - Static assets
  - `favicon.ico`
  - `manifest.json`
  - `robots.txt`
- `src/`
  - `pages/` - Next.js pages
  - `components/` - React components
  - `hooks/` - Custom React hooks
  - `utils/` - Utility functions
  - `styles/` - Tailwind CSS styles
  - `api/` - API client functions
  - `types/` - TypeScript types

#### `/backend`
Node.js/Express API servers
- `package.json` - Backend dependencies
- `tsconfig.json` - TypeScript configuration
- `.eslintrc.json` - ESLint configuration
- `src/`
  - `index.ts` - Application entry point
  - `middleware/` - Express middleware
  - `routes/` - API route handlers
  - `controllers/` - Business logic
  - `models/` - Database models
  - `services/` - Business services
  - `config/` - Configuration files
  - `utils/` - Utility functions
  - `types/` - TypeScript types
  - `database/`
    - `migrations/` - Database migrations
    - `seeds/` - Database seeds

#### `/services`
Microservices (one directory per service)
- `/auth-service` - Authentication and authorization
- `/video-service` - Video upload and management
- `/stream-service` - Live streaming management
- `/analytics-service` - Analytics and metrics

Each service contains:
- `Dockerfile`
- `package.json`
- `src/` - Service source code
- `tests/` - Service tests

#### `/infrastructure`
Infrastructure as Code (IaC)
- `/terraform/` - Terraform configurations
  - `main.tf`
  - `variables.tf`
  - `outputs.tf`
  - `environments/` - Environment-specific configs
- `/kubernetes/` - Kubernetes manifests
  - `/deployments/` - K8s deployment manifests
  - `/services/` - K8s service definitions
  - `/configmaps/` - ConfigMaps
  - `/secrets/` - Secrets
  - `/helm/` - Helm charts
- `/ansible/` - Ansible playbooks
- `/docker/` - Docker configurations
  - `Dockerfile.base` - Base image
  - `Dockerfile.prod` - Production image

#### `/scripts`
Automation scripts
- `setup.sh` - Initial project setup
- `deploy.sh` - Deployment scripts
- `migrate.sh` - Database migrations
- `seed.sh` - Database seeding
- `monitoring/` - Monitoring setup scripts

#### `/config`
Configuration files
- `prometheus.yml` - Prometheus configuration
- `grafana/` - Grafana dashboards and provisioning
- `elasticsearch/` - Elasticsearch configuration
- `logstash/` - Logstash configuration

#### `/docs`
Project documentation
- `ARCHITECTURE.md` - System architecture
- `API.md` - API documentation
- `DATABASE.md` - Database schema
- `DEPLOYMENT.md` - Deployment guide
- `CONTRIBUTING.md` - Contributing guidelines

#### `/.github`
GitHub specific files
- `/workflows/` - GitHub Actions workflows
  - `ci-cd.yml` - CI/CD pipeline
  - `security.yml` - Security checks
  - `release.yml` - Release automation
- `/ISSUE_TEMPLATE/` - Issue templates
- `/PULL_REQUEST_TEMPLATE/` - PR templates

#### `/tests`
Integration and end-to-end tests
- `/unit/` - Unit tests
- `/integration/` - Integration tests
- `/e2e/` - End-to-end tests

## Technology Stack

### Frontend
- Next.js 13+
- React 18+
- TypeScript
- Tailwind CSS
- Redux/Context API

### Backend
- Node.js 18+
- Express.js
- TypeScript
- PostgreSQL
- MongoDB
- Redis

### Infrastructure
- Docker
- Docker Compose
- Kubernetes
- Terraform
- Helm

### Monitoring
- Prometheus
- Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)

### CI/CD
- GitHub Actions
- Docker Registry
- ArgoCD (for GitOps)

## Getting Started

1. Clone the repository
2. Copy `.env.example` to `.env` and update values
3. Run `make up` to start all services
4. Visit http://localhost:3000 for the frontend

## Next Steps

1. Create frontend directory structure
2. Create backend directory structure
3. Create microservices
4. Add infrastructure-as-code
5. Add comprehensive documentation
6. Add integration and end-to-end tests
