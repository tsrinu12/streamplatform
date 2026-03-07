FROM node:18-alpine AS base

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

FROM node:18-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

COPY --from=base --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=base --chown=nodejs:nodejs /app .

USER nodejs

EXPOSE 3003

CMD ["node", "src/index.js"]
