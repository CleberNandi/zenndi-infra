# Zenndi Infra

## 📌 Responsibility

This repository orchestrates and provides the **local development and operations infrastructure** for the **Zenndi** ecosystem.

It delivers shared infrastructure components such as databases (PostgreSQL), cache (Redis), message broker (RabbitMQ), S3-compatible storage (MinIO), API Gateway (Nginx), observability stack (Prometheus, Grafana, OpenTelemetry), and operational utilities (bastion, backup scripts).

> This repository **does not contain business logic**. Application services (e.g. `zenndi-core`, `zenndi-auth`) are deployed independently and consume this infrastructure.

---

## 🧠 Domain

- **Bounded Context:** Infrastructure / Local Platform & Ops
- **Ubiquitous Language:** docker network, shared services, bastion, backups, observability
- **Source of Truth:** `docker-compose.yml` files under `base/`, `edge/`, `observability/`, `ops/` and environment variables in `.env`

---

## 📋 Requirements

- Docker 20.10+
- Docker Compose v2 (`docker compose`)
- GNU Make
- Python 3.10+ (for ops utilities)

---

## 🛠️ Installation

### Local Development

```bash
make network-create
make up-base
make up-edge
make up-obs
make up-ops
```

Or simply:

```bash
make up-all
```

---

## 📝 Configuration

All sensitive configuration is provided via `.env` (never commit it).

Main variables:

- `POSTGRES_PASSWORD`, `POSTGRES_MULTIPLE_DATABASES`
- `REDIS_PASSWORD`
- `RABBITMQ_PASSWORD`
- `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`
- `GRAFANA_ADMIN_PASSWORD`
- `TELEGRAM_TOKEN`, `CHAT_ID` (optional)

---

## 🔌 Usage

### Health Check

Core services expose:

- `GET /health`

Used by Docker healthchecks and operational validation.

### Metrics

Services are expected to expose:

- `GET /metrics`

Collected by Prometheus.

---

## 📊 Monitoring

- **Prometheus:** metrics scraping
- **Grafana:** dashboards and alerts
- **OpenTelemetry Collector:** traces and metrics forwarding

Local access:

- Grafana: http://127.0.0.1:3000
- Prometheus: http://127.0.0.1:9090

---

## 🧪 Testing

This repository does not include automated tests.

Validation is done through:

- Docker healthchecks
- Service startup consistency
- Manual smoke tests (`/health`, `/metrics`)

---

## 🚀 Production

This repository is **not production infrastructure**.

Production environments are expected to run on:

- VPS / Cloud Providers
- Cloudflare (DNS, TLS, proxy)
- Dedicated CI/CD pipelines

Local infra remains the **source of truth for development and ops parity**.

---

## 📦 Internal Structure

- `base/` — databases and shared services
- `edge/` — Nginx API Gateway
- `observability/` — Prometheus, Grafana, Otel
- `ops/` — bastion, backup tooling

---

## ⚠️ Rules & Constraints

- External Docker network is mandatory (`zenndi-network`)
- No public exposure of databases or brokers
- Secrets must live in `.env`
- Volumes persist data between restarts

---

## ✅ Checklist

- [x] External docker network
- [x] Health checks enabled
- [x] Metrics exposed
- [x] Observability stack running
- [x] Bastion access available

---

**Status:** Internal Infrastructure

