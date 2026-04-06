# StreamPlatform - AWS Cloud Deployment Guide

Complete guide for deploying StreamPlatform on AWS Cloud infrastructure.

Last Updated: April 6, 2026 | Version: 2.0.0 | Status: Production Ready

---

## Overview

StreamPlatform is a cloud-native microservices platform designed to run on AWS. This guide covers the complete AWS service mapping, deployment architecture, and operational best practices.

---

## AWS Service Mapping

| Component | Local/Generic | AWS Service | Terraform Module |
|-----------|---------------|-------------|------------------|
| **Compute** | Docker Containers | **AWS EKS** (Elastic Kubernetes Service) | `terraform/modules/eks/` |
| **AI/ML Inference** | Python/FastAPI | **AWS SageMaker** or EKS with G4dn instances | `terraform/modules/eks/` |
| **Video Storage** | Local Disk | **AWS S3** (Simple Storage Service) | `terraform/modules/s3/` |
| **Vector DB** | Pinecone | **AWS OpenSearch** with Vector Engine | `terraform/modules/opensearch/` |
| **Database** | PostgreSQL | **AWS RDS** (Relational Database Service) | `terraform/modules/rds/` |
| **NoSQL** | MongoDB | **AWS DocumentDB** | `terraform/modules/documentdb/` |
| **Caching** | Redis | **AWS ElastiCache** | `terraform/modules/elasticache/` |
| **Messaging** | Kafka | **AWS MSK** (Managed Streaming for Kafka) | `terraform/modules/msk/` |
| **CDN** | Nginx | **AWS CloudFront** | `terraform/modules/cloudfront/` |
| **Secrets** | Local env | **AWS Secrets Manager** | `terraform/modules/secrets-manager/` |
| **Monitoring** | Prometheus | **AWS CloudWatch** + Prometheus | `terraform/modules/cloudwatch/` |
| **IaC** | Terraform | **Terraform** on AWS | `terraform/` |
| **IAM** | Local roles | **AWS IAM** | `terraform/modules/iam/` |
| **VPC** | Docker network | **AWS VPC** | `terraform/modules/vpc/` |
| **WAF** | N/A | **AWS WAF** | `terraform/modules/waf/` |
| **ECR** | Docker registry | **AWS ECR** | `terraform/modules/ecr/` |
| **Lambda** | N/A | **AWS Lambda** | `terraform/modules/lambda/` |

---

## Deployment Architecture

```
                                    AWS Cloud (us-east-1)
    ┌─────────────────────────────────────────────────────────────────┐
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │                    CloudFront (CDN)                      │   │
    │  └────────────────────────────┬────────────────────────────┘   │
    │                               │                                │
    │  ┌────────────────────────────┴────────────────────────────┐   │
    │  │                    Application Load Balancer             │   │
    │  └────────────────────────────┬────────────────────────────┘   │
    │                               │                                │
    │  ┌────────────────────────────┴────────────────────────────┐   │
    │  │                    AWS EKS Cluster                       │   │
    │  │  ┌──────────────────────────────────────────────────┐   │   │
    │  │  │  Microservices Pods (10 services)                │   │   │
    │  │  │  - ai-service, auth-service, cv-service, etc.    │   │   │
    │  │  └──────────────────────────────────────────────────┘   │   │
    │  │  ┌──────────────────────────────────────────────────┐   │   │
    │  │  │  Ingress Controller + HPA Autoscaler             │   │   │
    │  │  └──────────────────────────────────────────────────┘   │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                               │                                │
    │  ┌────────────────────────────┴────────────────────────────┐   │
    │  │                    AWS Data Services                     │   │
    │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
    │  │  │  RDS     │  │ OpenSearch│  │ DocumentDB│              │   │
    │  │  │ (Postgres)│  │ (Vector) │  │ (Mongo)   │              │   │
    │  │  └──────────┘  └──────────┘  └──────────┘              │   │
    │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
    │  │  │ElastiCache│  │   MSK    │  │   S3     │              │   │
    │  │  │  (Redis) │  │  (Kafka) │  │ (Storage) │              │   │
    │  │  └──────────┘  └──────────┘  └──────────┘              │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                                                                 │
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │              Monitoring & Security                        │   │
    │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
    │  │  │CloudWatch│  │  Secrets │  │   WAF    │              │   │
    │  │  │  Logs    │  │ Manager  │  │ Firewall │              │   │
    │  │  └──────────┘  └──────────┘  └──────────┘              │   │
    │  └─────────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────────┘
```

---

## Algorithm Compatibility with AWS

### 1. V-JEPA (Video-JEPA)
- **Deployment:** AWS EKS with GPU-optimized instances (g4dn.xlarge)
- **Storage:** Video frames and model weights stored in S3
- **Inference:** Scaled via SageMaker endpoints or EKS with GPU nodes
- **Cost Optimization:** Spot instances for batch processing

### 2. Semantic Search (DPR/ColBERT)
- **Deployment:** Scalable on EKS
- **Vector Search:** Integrated with AWS OpenSearch with Vector Engine
- **Compute:** CPU-intensive tasks run on m5 or c5 instance families

### 3. NLP Processing (Whisper)
- **Deployment:** EKS with support for long-running pods
- **Audio Processing:** High-performance audio extraction
- **Scaling:** Auto-scaling based on SQS queue depth (using KEDA on EKS)

### 4. Content Moderation (YOLOv8)
- **Deployment:** EKS with GPU nodes
- **Real-time:** Low-latency inference via FastAPI
- **Batch:** Async processing via Celery workers

---

## Terraform Infrastructure

### Module Overview

| Module | Resources Created | Environment Support |
|--------|-------------------|--------------------|
| `vpc/` | VPC, subnets, NAT gateways, IGW | dev, stage, prod |
| `eks/` | EKS cluster, node groups, IAM roles | dev, stage, prod |
| `rds/` | PostgreSQL RDS instance, security groups | dev, stage, prod |
| `s3/` | Video storage buckets, CloudFront origin | dev, stage, prod |
| `elasticache/` | Redis cluster for caching | dev, stage, prod |
| `opensearch/` | OpenSearch domain with vector engine | dev, stage, prod |
| `documentdb/` | DocumentDB cluster (Mongo-compatible) | dev, stage, prod |
| `msk/` | Managed Kafka cluster | dev, stage, prod |
| `cloudfront/` | CDN distribution for video delivery | dev, stage, prod |
| `iam/` | IAM roles, policies, service accounts | dev, stage, prod |
| `secrets-manager/` | Secret storage and rotation | dev, stage, prod |
| `cloudwatch/` | Log groups, dashboards, alarms | dev, stage, prod |
| `waf/` | Web application firewall rules | prod only |
| `ecr/` | Container registry repositories | dev, stage, prod |
| `lambda/` | Serverless functions for events | dev, stage, prod |

### Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan dev environment
cd environments/dev
terraform plan

# Apply dev environment
terraform apply -auto-approve

# Repeat for stage and prod
cd ../stage && terraform apply
cd ../prod && terraform apply
```

---

## CI/CD Pipeline on AWS

### GitHub Actions Workflows

| Workflow | AWS Integration | Trigger |
|----------|-----------------|--------|
| `ci.yaml` | ECR push, SageMaker tests | Push, PR |
| `ci-cd.yaml` | Full EKS deployment | Push to main |
| `cd-dev.yaml` | Dev EKS deployment | Push to dev |
| `cd-stage.yaml` | Stage EKS deployment | Push to stage |
| `cd-prod.yaml` | Prod EKS deployment | Push to prod (manual approval) |

### Pipeline Steps

1. **Build:** Docker images built and pushed to AWS ECR
2. **Test:** Integration tests against dev EKS cluster
3. **Deploy:** Helm charts applied to target EKS environment
4. **Verify:** Health checks and smoke tests
5. **Monitor:** CloudWatch dashboards updated

---

## Kubernetes on EKS

### Cluster Configuration

| Setting | Value |
|---------|-------|
| Kubernetes Version | 1.29 |
| Node Groups | 3 (system, app, gpu) |
| Min Nodes | 3 |
| Max Nodes | 10 |
| Instance Types | m5.large, g4dn.xlarge |
| Autoscaling | Cluster Autoscaler + KEDA |

### Deployment Commands

```bash
# Update kubeconfig
aws eks update-kubeconfig --name streamplatform-eks --region us-east-1

# Verify cluster
kubectl get nodes

# Apply manifests
kubectl apply -f k8s/

# Install Helm charts
helm upgrade --install streamplatform ./helm/streamplatform \
  --values ./helm/streamplatform/values-prod.yaml \
  --namespace streamplatform
```

---

## Scalability & Availability

### Horizontal Pod Autoscaling (HPA)
- Automatically scale microservices based on CPU/Memory or custom metrics
- Configured per-service via `k8s/hpa.yaml`

### Multi-AZ Deployment
- EKS cluster spans 3 Availability Zones
- RDS with Multi-AZ failover
- ElastiCache with cluster mode enabled

### Disaster Recovery
- Daily RDS automated backups (30-day retention)
- S3 versioning and cross-region replication
- Terraform state backup in S3 with DynamoDB locking

---

## Cost Optimization

| Strategy | Savings | Implementation |
|----------|---------|---------------|
| Spot Instances | 60-70% | EKS node groups with spot capacity |
| S3 Intelligent Tiering | 30-40% | Automatic storage class transition |
| Reserved Instances | 40-50% | RDS and ElastiCache reservations |
| Lambda for Events | Pay-per-use | Serverless event processing |
| CloudWatch Logs Insights | 50% | Log sampling and retention policies |

---

## Security

### IAM Best Practices
- Least-privilege IAM roles per service
- IRSA (IAM Roles for Service Accounts) for EKS pods
- No long-lived credentials in code

### Network Security
- VPC with private subnets for all data services
- Security groups with minimal ingress rules
- WAF with OWASP Top 10 rules for production

### Secrets Management
- AWS Secrets Manager for all sensitive data
- Automatic rotation every 30 days
- No secrets in environment variables or code

---

## Monitoring & Observability

| Tool | AWS Service | Purpose |
|------|-------------|--------|
| Metrics | CloudWatch + Prometheus | Service health and performance |
| Logs | CloudWatch Logs | Centralized logging |
| Traces | AWS X-Ray + Tempo | Distributed tracing |
| Dashboards | Grafana + CloudWatch | Visualization |
| Alerts | CloudWatch Alarms + AlertManager | Proactive notifications |

---

## Getting Help

- **Terraform Issues:** Check `terraform/` modules and environments
- **EKS Issues:** Review `k8s/` manifests and Helm charts
- **AWS Service Issues:** Consult AWS documentation and CloudWatch logs
- **CI/CD Issues:** Check GitHub Actions workflow runs
- **Cost Issues:** Review AWS Cost Explorer and tags

---

**Created:** 2026-03-07 | **Last Updated:** 2026-04-06 | **Version:** 2.0.0 | **Status:** Production Ready
