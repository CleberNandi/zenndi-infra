#!/usr/bin/env python3
import os
import subprocess
import sys
from datetime import datetime

import requests
from dotenv import load_dotenv

# =========================
# Bootstrap
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(BASE_DIR)

load_dotenv(os.path.join(ROOT_DIR, ".env"))

try:
    import boto3
    import questionary
    from rich.console import Console
    from rich.panel import Panel
except ImportError:
    print("❌ Rode: uv add rich questionary boto3 requests python-dotenv")
    sys.exit(1)

console = Console()

# =========================
# Configurações
# =========================
DB_CONTAINER = os.getenv("POSTGRES_CONTAINER", "zenndi-postgres")
DB_USER = os.getenv("POSTGRES_USER", "dev")

BACKUP_DIR = os.path.join(BASE_DIR, "backups")
MINIO_BUCKET = os.getenv("MINIO_BACKUP_BUCKET", "zenndi-backups")
MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "http://localhost:9000")

MINIO_ACCESS_KEY = os.getenv("MINIO_ROOT_USER", "dev")
MINIO_SECRET_KEY = os.getenv("MINIO_ROOT_PASSWORD", "password")

TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
CHAT_ID = os.getenv("CHAT_ID")

# =========================
# Notificação
# =========================
def notify(message: str):
    console.print(f"[bold cyan]ℹ️ {message}[/bold cyan]")

    if TELEGRAM_TOKEN and CHAT_ID:
        try:
            requests.post(
                f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage",
                json={"chat_id": CHAT_ID, "text": f"🚀 Zenndi Ops\n{message}"},
                timeout=10,
            )
        except Exception as e:
            console.print(f"[red]Erro Telegram: {e}[/red]")

# =========================
# Backup
# =========================
def pg_backup(silent=False):
    os.makedirs(BACKUP_DIR, exist_ok=True)

    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    filename = f"zenndi_pg_{timestamp}.sql.gz"
    filepath = os.path.join(BACKUP_DIR, filename)

    cmd = f"docker exec {DB_CONTAINER} pg_dumpall -U {DB_USER} | gzip > {filepath}"

    try:
        subprocess.run(cmd, shell=True, check=True)
        if not silent:
            console.print(f"[green]✅ Backup criado: {filename}[/green]")

        upload_to_minio(filepath)
        return filepath

    except Exception as e:
        notify(f"❌ Falha no backup: {e}")
        return None

def upload_to_minio(path: str):
    s3 = boto3.client(
        "s3",
        endpoint_url=MINIO_ENDPOINT,
        aws_access_key_id=MINIO_ACCESS_KEY,
        aws_secret_access_key=MINIO_SECRET_KEY,
    )

    try:
        s3.head_bucket(Bucket=MINIO_BUCKET)
    except Exception:
        s3.create_bucket(Bucket=MINIO_BUCKET)

    s3.upload_file(path, MINIO_BUCKET, os.path.basename(path))
    notify(f"📦 Backup enviado ao MinIO: {os.path.basename(path)}")

# =========================
# CLI
# =========================
def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "pg_backup_silent":
            pg_backup(silent=True)
            return

    choice = questionary.select(
        "Zenndi Ops",
        choices=[
            "📦 Backup Postgres agora",
            "🚪 Sair",
        ],
    ).ask()

    if choice.startswith("📦"):
        pg_backup()
    else:
        console.print("👋 Saindo.")

if __name__ == "__main__":
    main()
