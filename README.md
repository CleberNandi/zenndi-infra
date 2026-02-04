# Zenndi Infra

## 📌 Responsabilidade

O **zenndi-infra** é a **base operacional local** do ecossistema Zenndi.

Este repositório é responsável por **orquestrar, padronizar e disponibilizar** toda a infraestrutura necessária para desenvolvimento e operações locais, servindo como **fonte de verdade do ambiente de desenvolvimento**.

Ele **NÃO** contém lógica de negócio. Serviços como `zenndi-auth`, `zenndi-core`, `zenndi-injestion` etc. são executados separadamente e **dependem** desta infra.

---

## 🧠 Domínio

- **Bounded Context:** Infraestrutura / Plataforma
- **Linguagem ubíqua:**
  - infra local
  - serviços compartilhados
  - bastion
  - observability
  - backups
- **Fonte de verdade para:**
  - Docker Compose base
  - Convenções de rede (`zenndi-network`)
  - Portas, volumes, healthchecks
  - Variáveis de ambiente de infra

---

## 📋 Requisitos

- Docker 20.10+
- Docker Compose (plugin ou binário)
- GNU Make
- Python 3.10+ (somente para utilitários em `ops/`)
- Rede Docker externa: `zenndi-network`

---

## 🛠️ Instalação

### Desenvolvimento Local

1. Criar a rede Docker externa (obrigatório):

```bash
docker network create zenndi-network
```

1. Criar o arquivo de variáveis de ambiente:

```bash
cp .env.example .env
```

1. Subir os stacks conforme necessidade:

```bash
docker compose -f base/docker-compose.yml up -d
```

Stacks opcionais:

```bash
docker compose -f edge/docker-compose.yml up -d
docker compose -f observability/docker-compose.yml up -d
docker compose -f ops/docker-compose.yml up -d
```

---

## 📝 Configuração

As principais variáveis são definidas via `.env`.

### Bancos e Mensageria

- `POSTGRES_PASSWORD`
- `POSTGRES_MULTIPLE_DATABASES`
- `REDIS_PASSWORD`
- `RABBITMQ_PASSWORD`

### Armazenamento (MinIO)

- `MINIO_ROOT_USER`
- `MINIO_ROOT_PASSWORD`
- `MINIO_BACKUP_BUCKET`

### Observability

- `GRAFANA_ADMIN_PASSWORD`

### Notificações (opcional)

- `TELEGRAM_TOKEN`
- `CHAT_ID`

---

## 🔌 Uso da Infra

Serviços Zenndi devem:

- Usar a rede `zenndi-network`
- Expor `/health` para liveness
- Expor `/metrics` (Prometheus)
- Não subir dependências duplicadas (Postgres, Redis, etc)

---

## ❤️ Health Check

Serviços críticos possuem `healthcheck` no Docker Compose.

Exemplo padrão esperado:

- `GET /health` → `200 OK`

---

## 📊 Monitoramento

- **Prometheus:** coleta métricas dos serviços
- **Grafana:** dashboards de métricas
- **OpenTelemetry:** pronto para traces distribuídos

UIs locais:

- Prometheus: <http://127.0.0.1:9090>
- Grafana: <http://127.0.0.1:3000>
- MinIO Console: <http://127.0.0.1:9001>

---

## 🧪 Testes

Este repositório não possui testes automatizados.

Validação ocorre via:

- `docker compose ps`
- `docker inspect --format '{{.State.Health.Status}}'`
- Acesso às UIs locais

---

## 🚀 Produção

⚠️ **Este repositório NÃO é usado diretamente em produção.**

Produção Zenndi utiliza:

- VPS dedicada
- Cloudflare (DNS, SSL, proxy)
- Infra provisionada manualmente ou via automação dedicada

Este repositório representa **apenas o ambiente local e operacional**.

---

## 📦 Estrutura de Pastas

```text
base/             # Postgres, Redis, RabbitMQ, MinIO
edge/             # Nginx (API Gateway)
observability/    # Prometheus, Grafana, Otel
ops/              # Bastion, backups, scripts operacionais
templates/        # Templates e docs auxiliares
```

---

## ⚠️ Regras Importantes

- `zenndi-network` é obrigatória
- Não expor serviços críticos publicamente
- Segredos nunca devem ir para o VCS
- Volumes garantem persistência local
- Infra local é **fonte de verdade de desenvolvimento**

---

## ✅ Checklist

- [ ] Rede Docker criada
- [ ] `.env` configurado
- [ ] Stacks necessários em execução
- [ ] Healthchecks OK
- [ ] Grafana acessível
- [ ] Backups testados

---

## ℹ️ Status do Serviço

![Status](https://img.shields.io/badge/Status-Internal_Service-red?style=for-the-badge)

---

## 📄 Licença

Uso interno — Zenndi
