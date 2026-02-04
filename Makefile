# =====================================
# ZENNDI-INFRA — MAKEFILE v1
# =====================================

ENV_FILE ?= .env
NETWORK  ?= zenndi-network

DC = docker compose --env-file $(ENV_FILE)

.DEFAULT_GOAL := help

# =====================================
# INTERNAL HELPERS
# =====================================

define print
	@printf "\033[36m%-22s\033[0m %s\n" $(1) $(2)
endef

# =====================================
# HELP
# =====================================

help:
	@echo ""
	@echo "Zenndi Infra — Available commands:"
	@echo ""
	$(call print,"make network-create","Create docker network (if not exists)")
	$(call print,"make network-rm","Remove docker network")
	@echo ""
	$(call print,"make up-base","Start base services (db\, redis\, minio)")
	$(call print,"make down-base","Stop base services")
	$(call print,"make logs-base","Tail base logs")
	$(call print,"make ps-base","List base containers")
	@echo ""
	$(call print,"make up-edge","Start edge (nginx gateway)")
	$(call print,"make down-edge","Stop edge")
	$(call print,"make logs-edge","Tail edge logs")
	$(call print,"make ps-edge","List edge containers")
	@echo ""
	$(call print,"make up-obs","Start observability stack")
	$(call print,"make down-obs","Stop observability stack")
	$(call print,"make logs-obs","Tail observability logs")
	$(call print,"make ps-obs","List observability containers")
	@echo ""
	$(call print,"make up-ops","Start ops services")
	$(call print,"make down-ops","Stop ops services")
	$(call print,"make logs-ops","Tail ops logs")
	$(call print,"make ops-local","Open local SSH tunnel")
	$(call print,"make ops-dev","Open dev SSH tunnel")
	$(call print,"make ops-prod","Open prod SSH tunnel")
	@echo ""
	$(call print,"make up-all","Start all stacks")
	$(call print,"make down-all","Stop all stacks")
	$(call print,"make status","List running containers")
	$(call print,"make clean","Docker system prune")
	@echo ""

# =====================================
# NETWORK
# =====================================

network-create:
	@docker network inspect $(NETWORK) >/dev/null 2>&1 || \
	docker network create $(NETWORK)

network-rm:
	@docker network rm $(NETWORK) >/dev/null 2>&1 || true

# =====================================
# BASE
# =====================================

up-base: network-create
	$(DC) -f base/docker-compose.yml up -d

down-base:
	$(DC) -f base/docker-compose.yml down -v

logs-base:
	$(DC) -f base/docker-compose.yml logs -f --tail=100

ps-base:
	$(DC) -f base/docker-compose.yml ps

restart-base: down-base up-base

# =====================================
# EDGE
# =====================================

up-edge: network-create
	$(DC) -f edge/docker-compose.yml up -d

down-edge:
	$(DC) -f edge/docker-compose.yml down

logs-edge:
	$(DC) -f edge/docker-compose.yml logs -f --tail=100

ps-edge:
	$(DC) -f edge/docker-compose.yml ps

restart-edge: down-edge up-edge

# =====================================
# OBSERVABILITY
# =====================================

up-obs: network-create
	$(DC) -f observability/docker-compose.yml up -d

down-obs:
	$(DC) -f observability/docker-compose.yml down

logs-obs:
	$(DC) -f observability/docker-compose.yml logs -f --tail=100

ps-obs:
	$(DC) -f observability/docker-compose.yml ps

restart-obs: down-obs up-obs

# =====================================
# OPS
# =====================================

up-ops: network-create
	$(DC) -f ops/docker-compose.yml up -d

down-ops:
	$(DC) -f ops/docker-compose.yml down

logs-ops:
	$(DC) -f ops/docker-compose.yml logs -f --tail=100

ops-local:
	cd ops && ./zenndi-tunnel.sh local

ops-dev:
	cd ops && ./zenndi-tunnel.sh dev

ops-prod:
	cd ops && ./zenndi-tunnel.sh prod

# =====================================
# GLOBAL
# =====================================

up-all: up-base up-edge up-obs up-ops

down-all: down-edge down-obs down-ops down-base

status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

clean:
	docker system prune -f
