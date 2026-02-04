# Zenndi infra

## 📌 Responsabilidade

Este repositório orquestra e disponibiliza a infraestrutura de desenvolvimento e operações local para o projeto **Zenndi**.

O repositório fornece e mantém: bancos de dados compartilhados (Postgres), cache (Redis), broker de mensagens (RabbitMQ), armazenamento S3 compatível (MinIO), API Gateway (Nginx), observability (Prometheus, Grafana, OpenTelemetry) e utilitários de operações (bastion, scripts de backup). Não contém a lógica de negócio dos serviços (ex.: `zenndi-core`, `zenndi-auth`), que devem ser implantados separadamente.

## 🧠 Domínio

- Bounded Context: **Infra / Plataforma local de desenvolvimento e ops**
- Linguagem ubíqua: network `zenndi-network`, serviços compartilhados, backup, bastion, observability
- Fonte de verdade para: arquivos `docker-compose.yml` em `base/`, `edge/`, `observability/`, `ops/` e variáveis em `.env`

## 📤 Eventos Publicados

- Notificações de operação (ex.: backup concluído) enviadas opcionalmente via **Telegram** (via `ops/manage.py`).
- Artefatos (backups) publicados no **MinIO** (S3 API) — observável por outros sistemas.

> Observação: infra não é responsável por publicar eventos de domínio — os serviços (cada aplicação) usam o **RabbitMQ** para mensagens de domínio.

## 📥 Eventos Consumidos

- Infra não consome eventos de domínio como responsabilidade principal. Observability (Prometheus) "consome" (coleta) métricas expostas por serviços (`/metrics`).

## 🔗 Dependências

- Docker e Docker Compose (ou `docker compose` moderno)
- Rede Docker externa: `zenndi-network` (criar com `docker network create zenndi-network`)
- Arquivo `.env` com variáveis sensíveis:
  - `POSTGRES_PASSWORD`, `POSTGRES_USER` (opcional), `POSTGRES_MULTIPLE_DATABASES`
  - `REDIS_PASSWORD`
  - `RABBITMQ_PASSWORD`
  - `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`, `MINIO_ENDPOINT` (opcional)
  - `GRAFANA_ADMIN_PASSWORD`
  - `TELEGRAM_TOKEN`, `CHAT_ID` (opcional para notificações)
- Python para utilitários em `ops/` com dependências: `rich`, `questionary`, `boto3`, `requests`, `python-dotenv`

Portas e escopo de acesso (observação importante):

- A maioria dos serviços está vinculada a `127.0.0.1` (acesso local / via SSH Túnel / Bastion).
- `nginx` (API Gateway) expõe `80:80` por padrão (entrada pública local) e `bastion` expõe `2222`.

## ⚠️ Regras Importantes

- **Rede externa obrigatória**: `zenndi-network` deve existir. Não inicie sem ela.
- **Não exponha** serviços críticos (Postgres, Redis, RabbitMQ, MinIO) publicamente em produção — use apenas `127.0.0.1` ou túnel via bastion.
- **Manter segredos fora do VCS**: use `.env` e não commite credenciais.
- **Persistência**: os volumes declarados preservam dados entre reinícios (Postgres, Redis, RabbitMQ, MinIO, Grafana, Prometheus).
- **Healthchecks** estão configurados para serviços essenciais; mantenha-os ativos para orquestração segura.
- **Nginx configs** e `conf.d/` no `edge/` estão esperando configurações específicas de roteamento; crie os arquivos conforme sua arquitetura de APIs.

## 📦 Estrutura Interna

- `base/` — Serviços de infra compartilhada: `postgres`, `redis`, `rabbitmq`, `minio` + script de init (`init-multiple-dbs.sh`)
- `edge/` — API Gateway (`nginx`) e suas configs
- `observability/` — `prometheus`, `grafana`, `otel` (collector)
- `ops/` — `manage.py` (rotinas de backup e uploads para MinIO), `bastion/`, scripts e backups
- `templates/` — modelos e documentação

## 🔄 Fluxos Relevantes

1. Bootstrapping da infra
   - Crie a rede: `docker network create zenndi-network`
   - Configure `.env` com senhas e variáveis necessárias
   - Suba os stacks (exemplos):
     - `docker compose -f base/docker-compose.yml up -d`
     - `docker compose -f edge/docker-compose.yml up -d`
     - `docker compose -f observability/docker-compose.yml up -d`
     - `docker compose -f ops/docker-compose.yml up -d`

2. Inicialização de bancos
   - `POSTGRES_MULTIPLE_DATABASES` (ex: `zenndi_core,zenndi_auth,zenndi_scanner`) é usado por `init-multiple-dbs.sh` para criar DBs automaticamente no primeiro start do container Postgres.

3. Fluxo de Backup (Operações)
   - Executar: `python ops/manage.py` e escolher **Backup Postgres agora**
   - O script gera um dump, comprime e faz upload para o **MinIO** (bucket configurável via `MINIO_BACKUP_BUCKET`).
   - Notificações via Telegram são opcionais e configuráveis com `TELEGRAM_TOKEN` e `CHAT_ID`.

4. Observabilidade
   - Prometheus scrapes serviços configurados em `observability/prometheus/prometheus.yml` (espera que cada serviço exponha `/metrics` em `:8000`).
   - Grafana consulta Prometheus; Otel Collector (configurável) encaminha traces.

5. Acesso a UIs locais
   - MinIO Console: `http://127.0.0.1:9001` (ou via SSH Tunnel / Bastion)
   - Prometheus: `http://127.0.0.1:9090`
   - Grafana: `http://127.0.0.1:3000`
   - Bastion SSH (testes locais): `ssh -p 2222 dev@localhost`

---

💡 Dicas rápidas

- Verifique se `nginx` possui configurações em `edge/nginx/` antes de usá-lo como gateway.
- Atualize senhas por padrão em ambientes de produção.
- Expanda `prometheus.yml` com seus serviços quando adicionar novas APIs.

---

Se quiser, eu posso também:

1. Gerar um arquivo de exemplo `.env.example` com as variáveis essenciais ✅
2. Criar um pequeno playbook (scripts) para criar a rede, validar serviços e executar backups automaticamente ✅

Quer que eu adicione `.env.example` agora? 🔧
