#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"
HA_CONFIG="/home/ubuntu/homeassistant"

echo "================================="
echo "      HA-Migrate Restore"
echo "================================="

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "[ERROR] No backup found!"
    exit 1
fi

echo "Latest backup:"
echo "$LATEST_BACKUP"

read -p "Restore latest backup? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Restore cancelled."
    exit 0
fi

sudo docker stop homeassistant
sudo cp -a "$HA_CONFIG" "${HA_CONFIG}.bak"

sudo tar -xzf "$LATEST_BACKUP" -C /

sudo chown -R ubuntu:ubuntu "$HA_CONFIG"

sudo docker start homeassistant

echo "Restore completed successfully."
