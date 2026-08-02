#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"
HA_CONFIG="/home/ubuntu/homeassistant"

echo "================================="
echo "      HA-Migrate Restore"
echo "================================="
echo

mapfile -t BACKUPS < <(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null)

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "[ERROR] No backup files found!"
    exit 1
fi

echo "Available Backups:"
echo

for i in "${!BACKUPS[@]}"; do
    FILE=$(basename "${BACKUPS[$i]}")
    echo "$((i+1)). $FILE"
done

echo
read -p "Select backup number: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Invalid input."
    exit 1
fi

INDEX=$((CHOICE-1))

if [ $INDEX -lt 0 ] || [ $INDEX -ge ${#BACKUPS[@]} ]; then
    echo "[ERROR] Invalid backup number."
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$INDEX]}"

echo
echo "[INFO] Selected:"
echo "$SELECTED_BACKUP"

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
sudo rm -rf "${HA_CONFIG}.bak"
sudo cp -a "$HA_CONFIG" "${HA_CONFIG}.bak"

echo
echo "[INFO] Restoring backup..."

if sudo tar -xzf "$SELECTED_BACKUP" -C /; then

    sudo chown -R ubuntu:ubuntu "$HA_CONFIG"

    echo
    echo "[INFO] Starting Home Assistant..."
    sudo docker start homeassistant

    echo
    echo "[INFO] Removing temporary safety backup..."
    sudo rm -rf "${HA_CONFIG}.bak"

    echo
    echo "[OK] Restore completed successfully."

else

    echo
    echo "[ERROR] Restore failed!"
    echo "[INFO] Rolling back previous configuration..."

    sudo rm -rf "$HA_CONFIG"

    if [ -d "${HA_CONFIG}.bak" ]; then
        sudo mv "${HA_CONFIG}.bak" "$HA_CONFIG"
        sudo chown -R ubuntu:ubuntu "$HA_CONFIG"
    fi

    echo
    echo "[INFO] Starting Home Assistant..."
    sudo docker start homeassistant

    echo
    echo "[OK] Rollback completed."

    exit 1
fi
