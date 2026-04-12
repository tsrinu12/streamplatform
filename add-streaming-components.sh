#!/usr/bin/env bash
# ============================================================
# StreamPlatform — Add 5 new streaming components to repo
# Run this from the ROOT of your cloned streamplatform repo
# Usage:  bash add-streaming-components.sh
# ============================================================
set -euo pipefail

REPO_ROOT="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   StreamPlatform — Adding 5 Streaming Components    ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Repo root: $REPO_ROOT"
echo ""

# ── Validate we're in the right repo ──────────────────────
if [ ! -f "$REPO_ROOT/docker-compose.yml" ] || [ ! -d "$REPO_ROOT/services" ]; then
  echo "ERROR: Run this script from the root of the streamplatform repo."
  exit 1
fi

# ── 1. streaming-gateway ──────────────────────────────────
echo "▶ [1/5] streaming-gateway (Go HLS/DASH gateway)..."
mkdir -p "$REPO_ROOT/services/streaming-gateway/src"
mkdir -p "$REPO_ROOT/services/streaming-gateway/k8s"

cp -v streaming-gateway/src/main.go      "$REPO_ROOT/services/streaming-gateway/src/"
cp -v streaming-gateway/src/go.mod       "$REPO_ROOT/services/streaming-gateway/src/"
cp -v streaming-gateway/Dockerfile       "$REPO_ROOT/services/streaming-gateway/"
cp -v streaming-gateway/k8s/deployment.yaml "$REPO_ROOT/services/streaming-gateway/k8s/"
echo "   ✓ streaming-gateway"

# ── 2. drm-service ────────────────────────────────────────
echo "▶ [2/5] drm-service (Widevine + FairPlay license server)..."
mkdir -p "$REPO_ROOT/services/drm-service/src"
mkdir -p "$REPO_ROOT/services/drm-service/k8s"

cp -v drm-service/src/main.py            "$REPO_ROOT/services/drm-service/src/"
cp -v drm-service/src/requirements.txt   "$REPO_ROOT/services/drm-service/src/"
cp -v drm-service/Dockerfile             "$REPO_ROOT/services/drm-service/"
cp -v drm-service/k8s/deployment.yaml    "$REPO_ROOT/services/drm-service/k8s/"
echo "   ✓ drm-service"

# ── 3. upload-service ─────────────────────────────────────
echo "▶ [3/5] upload-service (resumable S3 multipart upload)..."
mkdir -p "$REPO_ROOT/services/upload-service/src"
mkdir -p "$REPO_ROOT/services/upload-service/k8s"

cp -v upload-service/src/main.py         "$REPO_ROOT/services/upload-service/src/"
cp -v upload-service/src/requirements.txt "$REPO_ROOT/services/upload-service/src/"
cp -v upload-service/Dockerfile          "$REPO_ROOT/services/upload-service/"
cp -v upload-service/k8s/deployment.yaml "$REPO_ROOT/services/upload-service/k8s/"
echo "   ✓ upload-service"

# ── 4. abr-optimizer ──────────────────────────────────────
echo "▶ [4/5] abr-optimizer (Pensieve ML + MPC bitrate selection)..."
mkdir -p "$REPO_ROOT/services/abr-optimizer/src"
mkdir -p "$REPO_ROOT/services/abr-optimizer/k8s"

cp -v abr-optimizer/src/main.py          "$REPO_ROOT/services/abr-optimizer/src/"
cp -v abr-optimizer/src/requirements.txt "$REPO_ROOT/services/abr-optimizer/src/"
cp -v abr-optimizer/Dockerfile           "$REPO_ROOT/services/abr-optimizer/"
cp -v abr-optimizer/k8s/deployment.yaml  "$REPO_ROOT/services/abr-optimizer/k8s/"
echo "   ✓ abr-optimizer"

# ── 5. cdn-edge-config Terraform module ───────────────────
echo "▶ [5/5] cdn-edge-config (CloudFront + Lambda@Edge Terraform module)..."
mkdir -p "$REPO_ROOT/terraform/modules/cdn-edge-config/lambda"

cp -v cdn-edge-config/main.tf            "$REPO_ROOT/terraform/modules/cdn-edge-config/"
cp -v cdn-edge-config/variables.tf       "$REPO_ROOT/terraform/modules/cdn-edge-config/"
cp -v cdn-edge-config/outputs.tf         "$REPO_ROOT/terraform/modules/cdn-edge-config/"
cp -v cdn-edge-config/lambda/token_validator.js "$REPO_ROOT/terraform/modules/cdn-edge-config/lambda/"
echo "   ✓ cdn-edge-config"

# ── 6. Updated .gitlab-ci.yml ─────────────────────────────
echo "▶ Updating .gitlab-ci.yml with new services..."
cp -v .gitlab-ci.yml "$REPO_ROOT/.gitlab-ci.yml"
echo "   ✓ .gitlab-ci.yml updated"

# ── Git commit ────────────────────────────────────────────
echo ""
echo "All files copied. Staging for git..."
cd "$REPO_ROOT"

git add \
  services/streaming-gateway/ \
  services/drm-service/ \
  services/upload-service/ \
  services/abr-optimizer/ \
  terraform/modules/cdn-edge-config/ \
  .gitlab-ci.yml

echo ""
echo "Files staged. Committing..."
git commit -m "feat: add 5 critical streaming components

- services/streaming-gateway: Go HLS/DASH gateway with S3, signed URLs,
  Range request support, session management, Prometheus metrics, HPA
- services/drm-service: Widevine CENC + FairPlay license server with
  AWS Secrets Manager key storage, Redis caching, key rotation API
- services/upload-service: Resumable multipart S3 upload (up to 100GB),
  presigned URLs per part, SQS transcode trigger, Redis progress tracking
- services/abr-optimizer: Pensieve A3C neural net + MPC fallback for
  ML-based adaptive bitrate selection, QoE scoring, session telemetry
- terraform/modules/cdn-edge-config: CloudFront distribution with OAC,
  per-behaviour cache policies, Lambda@Edge token auth, geo-restriction,
  signed URL key group, WAF integration, real-time logging
- .gitlab-ci.yml: updated SERVICES list and deploy needs for all 4 new
  services (build, publish, deploy-dev, deploy-prod)"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Done! Push to GitLab to trigger CI/CD pipeline:  ║"
echo "║                                                      ║"
echo "║   git push origin main                              ║"
echo "║                                                      ║"
echo "║   Or push a version tag for production:             ║"
echo "║   git tag v1.1.0 && git push origin v1.1.0         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
