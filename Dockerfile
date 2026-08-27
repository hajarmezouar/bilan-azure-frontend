# syntax=docker/dockerfile:1
# ──────────────────────────────────────────────────────────────────────────────
# Multi-stage build for the AKS track (piste "AKS", see helm/ and
# .github/workflows/aks-deploy.yml). swa-deploy.yml (Static Web Apps track)
# never uses this image.
#
# API_BASE_URL is baked into the Angular bundle at image build time. Browser
# bundles cannot safely contain API secrets, so authentication remains a
# server-side concern.
# ──────────────────────────────────────────────────────────────────────────────

# ── Build stage ─────────────────────────────────────────────────────────────
FROM node:24-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG API_BASE_URL
RUN test -n "$API_BASE_URL" || (echo "API_BASE_URL build arg is required" && exit 1)
RUN sed -i "s#https://REPLACE_WITH_PROD_API_URL/api#${API_BASE_URL}#" src/environments/environment.ts

RUN npm run build:prod

# ── Runtime stage ────────────────────────────────────────────────────────────
FROM nginxinc/nginx-unprivileged:alpine
USER root
RUN apk upgrade --no-cache
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/azure-quiz-frontend/browser /usr/share/nginx/html

USER 101

EXPOSE 8080
