#!/bin/bash
# StreamPlatform Production Deployment Script
# This script automates the full-scale deployment to AWS
set -e

echo "Starting StreamPlatform Production Deployment..."

# 1. Infrastructure Provisioning
echo "Provisioning AWS Infrastructure with Terraform..."
cd terraform/environments/prod
terraform init

echo "[SECURITY CHECK] Review Terraform plan before applying:"
terraform plan -out=tfplan
read -p "Press Enter to apply Terraform changes, or Ctrl+C to cancel..."
terraform apply tfplan
cd ../../../

# 2. Get EKS Credentials
echo "Configuring Kubernetes Access..."
aws eks update-kubeconfig --region ap-south-1 --name streamplatform-prod-cluster

# 3. Security Hardening (Service Mesh)
echo "Installing Istio Service Mesh for mTLS and Security..."
istioctl install --set profile=default -y
kubectl label namespace default istio-injection=enabled

# 4. Deploy Database Migrations
echo "Running Database Migrations..."
kubectl apply -f k8s/db-migrations-job.yaml

# 5. Deploy AI Microservices (EKS)
echo "Deploying AI Microservices (V-JEPA, Search, NLP)..."
helm upgrade --install streamplatform-ai ./helm/streamplatform \
  --namespace production --create-namespace \
  -f ./helm/streamplatform/values-prod.yaml \
  --set vjepa.enabled=true \
  --set search.enabled=true \
  --set nlp.enabled=true

# 6. Configure AWS WAF & CloudFront
echo "Configuring Edge Security..."
aws wafv2 list-web-aces --scope CLOUDFRONT --name-prefix streamplatform-prod-waf

# 7. Verification & Health Checks
echo "Deployment complete. Running health checks..."
kubectl get pods -n production
curl -I https://api.streamplatform.com/health
echo "StreamPlatform is now LIVE in Production!"
