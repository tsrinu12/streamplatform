# Auth Service Dockerfile - Multi-stage build with pinned base images
# Fixes: Pinned node.js and Alpine versions, health check

# ==============================================================================
# Stage 1: Base
# ==============================================================================
# Pin to specific Node.js version for security and reproducibility
FROM node:18.18.2-alpine3.18 AS base

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY . .

# ==============================================================================
# Stage 2: Production (Minimal image)
# ==============================================================================
# Pin to specific Alpine version instead of 'latest'
FROM node:18.18.2-alpine3.18 AS production

WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Copy node_modules from base stage
COPY --from=base --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code from base stage
COPY --from=base --chown=nodejs:nodejs /app .

# Switch to non-root user
USER nodejs

# Expose application port
EXPOSE 3001

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# Start the application
CMD ["node", "src/index.js"]
