# syntax=docker.io/docker/dockerfile:1

# Development Stage
FROM node:alpine AS development
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile
COPY . .
CMD ["pnpm", "run", "dev"]

# Production Build Stage
FROM node:alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
ENV NEXT_TELEMETRY_DISABLED=1# ENV NEXT_TELEMETRY_DISABLED=1
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile --prod
COPY . .
RUN pnpm run build

# Production Runner Stage
FROM node:alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY package.json ./
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile --prod
CMD ["pnpm", "run", "start"]
