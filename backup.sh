#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/homeassistant-$DATE.tar.gz"


mkdir -p "$BACKUP_DIR"

echo "================================="
echo "      HA-Migrate Backup"
echo "================================="
echo

echo "[INFO] Creating backup..."

sudo tar -czf "$BACKUP_FILE" /home/ubuntu/homeassistant

if [ $? -eq 0 ]; then
    echo "[OK] Backup created:"
    echo "$BACKUP_FILE"
else
    echo "[ERROR] Backup failed!"
fi
