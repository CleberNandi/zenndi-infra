#!/usr/bin/env bash

# chmod +x zenndi-tunnel.sh
# Dica PRO (não pedir senha toda hora)
# Configure SSH key no servidor:
# ssh-copy-id -i ~/.ssh/zenndi_prod_ed25519.pub zenndi@45.182.xxx.xxx
#!/usr/bin/env bash

#!/usr/bin/env bash

# Configuração
ENV=${1:-local}
DB_LOCAL_PORT=5435      # Porta local para acessar o Postgres
PROM_LOCAL_PORT=9091     # Porta local para o Prometheus
GRAF_LOCAL_PORT=3001     # Porta local para o Grafana

case "$ENV" in
  prod)
    SSH_HOST="zenndi-prod"
    SSH_USER="" # Deixe vazio se estiver no ~/.ssh/config ou defina ex: "ubuntu@"
    SSH_PORT=22
    ;;
  dev)
    SSH_HOST="zenndi-dev"
    SSH_USER=""
    SSH_PORT=22
    ;;
  local)
    # Configuração para o Container Bastion
    SSH_HOST="localhost"
    SSH_USER="dev@"
    SSH_PORT=2222
    echo "⚠️  Modo Local: Certifique-se que 'docker compose up' está rodando com o serviço 'bastion'."
    ;;
  *)
    echo "Uso: $0 [local|dev|prod]"
    exit 1
    ;;
esac

echo "🔐 Zenndi SSH Tunnel ($ENV)"
echo "------------------------------------------------"
echo "🐘 Postgres   → localhost:$DB_LOCAL_PORT (Remoto: 5432)"
echo "🔥 Prometheus → localhost:$PROM_LOCAL_PORT (Remoto: 9090)"
echo "📊 Grafana    → localhost:$GRAF_LOCAL_PORT (Remoto: 3000)"
echo "------------------------------------------------"
echo "CTRL+C para encerrar a conexão."
echo ""

# Verifica se é local e tenta usar sshpass se disponível para não pedir senha
# Senha do container bastion é 'password' conforme o docker-compose
if [ "$ENV" == "local" ] && command -v sshpass &> /dev/null; then
    PREFIX_CMD="sshpass -p password"
else
    PREFIX_CMD=""
fi

$PREFIX_CMD ssh -N \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -p $SSH_PORT \
  -L $DB_LOCAL_PORT:zenndi-postgres:5432 \
  -L $PROM_LOCAL_PORT:zenndi-prometheus:9090 \
  -L $GRAF_LOCAL_PORT:zenndi-grafana:3000 \
  ${SSH_USER}${SSH_HOST}