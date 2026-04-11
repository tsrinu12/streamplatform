# Notification Service Dockerfile - Multi-stage build with security hardening
# Fixes: Pinned base image versions, absolute WORKDIR path, non-root user, health check

# ==============================================================================
# Stage 1: Builder
# ==============================================================================
# Pin to specific Go version for security and reproducibility
FROM golang:1.21.8-alpine3.18 AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Set absolute WORKDIR path
WORKDIR /app

# Copy go mod files first for better layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build with CGO disabled for Alpine compatibility
RUN CGO_ENABLED=0 GOOS=linux go build -o notification-service ./cmd/server

# ==============================================================================
# Stage 2: Runtime (Minimal production image)
# ==============================================================================
# Pin to specific Alpine version instead of 'latest'
FROM alpine:3.18.4

# Add CA certificates
RUN apk --no-cache add ca-certificates

# Set absolute WORKDIR path (no trailing slash)
WORKDIR /root

# Create non-root user for security
RUN addgroup -g 1001 -S appuser && adduser -S appuser -u 1001

# Copy binary from builder with proper ownership
COPY --from=builder --chown=appuser:appuser /app/notification-service .

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8004

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8004/health || exit 1

# Run the application
CMD ["./notification-service"]
