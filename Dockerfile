# =========================
# Builder stage
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

# Dependencias necesarias para sharp
RUN apk add --no-cache \
  libc6-compat \
  vips-dev \
  build-base \
  python3

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# =========================
# Production stage
# =========================
FROM node:20-alpine

WORKDIR /app

# SOLO dependencias runtime para sharp
RUN apk add --no-cache \
  libc6-compat \
  vips

# Copiar lo ya compilado
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

ENV NODE_ENV=production

EXPOSE 10000

CMD ["node", "dist/main.js"]

