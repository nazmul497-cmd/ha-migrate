#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"

echo "================================="
echo "      HA-Migrate Verify"
echo "================================="
echo

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "[ERROR] No backup found!"
    exit 1
fi

echo "[OK] Backup found:"
echo "$LATEST_BACKUP"

echo
echo "[INFO] Checking archive..."

if tar -tzf "$LATEST_BACKUP" >/dev/null 2>&1; then
    echo "[OK] Archive is valid"
else
    echo "[ERROR] Archive is corrupted"
    exit 1
fi

echo
echo "[INFO] Backup size:"
du -h "$LATEST_BACKUP"

echo
echo "Backup Status: VALID"
