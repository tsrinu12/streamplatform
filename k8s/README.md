# Kubernetes Manifests Directory

This directory contains Kubernetes manifests and GitOps configurations for the StreamPlatform.

## Structure

```
k8s/
├── argocd/                  # ArgoCD Application definitions for GitOps
│   ├── applications/
│   │   ├── auth-service.yaml
│   │   ├── video-service.yaml
│   │   ├── ai-service.yaml
│   │   ├── reward-service.yaml
│   │   ├── transcode-service.yaml
│   │   └── frontend.yaml
│   ├── appsets/            # ApplicationSets for multi-environment deployment
│   └── projects/           # ArgoCD Projects
│
├── cluster-addons/          # Infrastructure components
│   ├── ingress-nginx/      # Ingress controller configuration
│   ├── cert-manager/       # TLS certificate management
│   ├── external-dns/       # Automatic DNS management
│   └── sealed-secrets/     # Encrypted secrets management
│
└── observability/           # Monitoring and observability stack
    ├── prometheus/         # Prometheus configuration
    ├── grafana/            # Grafana dashboards
    ├── loki/               # Log aggregation
    └── tempo/              # Distributed tracing
```

## Usage

### GitOps with ArgoCD

All application deployments are managed through ArgoCD for GitOps-based continuous delivery.

### Apply Cluster Addons

```bash
# Install ingress controller
kubectl apply -f cluster-addons/ingress-nginx/

# Install cert-manager for TLS
kubectl apply -f cluster-addons/cert-manager/
```

### Deploy Observability Stack

```bash
kubectl apply -f observability/prometheus/
kubectl apply -f observability/grafana/
```

## Prerequisites

- Kubernetes cluster (EKS) provisioned via Terraform
- kubectl configured with cluster access
- ArgoCD installed on the cluster

## Related

- Helm charts: `../helm/streamplatform/`
- Terraform infrastructure: `../terraform/`
- Documentation: See TIER_IMPLEMENTATION_STATUS.md for current progress
