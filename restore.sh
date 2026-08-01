#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"
HA_CONFIG="/home/ubuntu/homeassistant"

echo "================================="
echo "      HA-Migrate Restore"
echo "================================="
echo

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "[ERROR] No backup found!"
    exit 1
fi

echo "[INFO] Latest backup:"
echo "$LATEST_BACKUP"
echo

read -p "Restore this backup? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo
echo "[INFO] Stopping Home Assistant..."
sudo docker stop homeassistant

echo
echo "[INFO] Creating safety backup..."
sudo mv "$HA_CONFIG" "${HA_CONFIG}.old.$(date +%F-%H%M%S)"

echo
echo "[INFO] Restoring backup..."
sudo mkdir -p "$HA_CONFIG"
sudo tar -xzf "$LATEST_BACKUP" -C /

echo
echo "[INFO] Fixing permissions..."
sudo chown -R ubuntu:ubuntu "$HA_CONFIG"

echo
echo "[INFO] Starting Home Assistant..."
sudo docker start homeassistant

echo
echo "[OK] Restore completed successfully!"
