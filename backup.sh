#!/bin/bash

BACKUP_DIR="$HOME/ha-migrate/backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/homeassistant-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "================================="
echo "        HA-Migrate Backup"
echo "================================="
echo

echo "[INFO] Creating backup..."

sudo tar -czf "$BACKUP_FILE" /home/ubuntu/homeassistant

if [ $? -eq 0 ]; then

    echo "[OK] Backup created:"
    echo "$BACKUP_FILE"
    echo

    echo "[INFO] Uploading backup to Google Drive..."

    rclone mkdir gdrive:HA-Migrate/Daily >/dev/null 2>&1
    rclone copy "$BACKUP_FILE" gdrive:HA-Migrate/Daily

    if [ $? -eq 0 ]; then
        echo "[OK] Uploaded to Google Drive successfully."
    else
        echo "[ERROR] Google Drive upload failed."
    fi

    echo
    echo "[INFO] Cleaning old local backups..."

    LOCAL_KEEP=3

    cd "$BACKUP_DIR" || exit 1

    ls -1t homeassistant-*.tar.gz 2>/dev/null | tail -n +$((LOCAL_KEEP+1)) | while read file
    do
        echo "[DELETE] Local -> $file"
        rm -f "$file"
    done

    echo "[OK] Local retention complete."

    echo
    echo "[INFO] Cleaning old Google Drive backups..."

    GDRIVE_KEEP=30

    COUNT=$(rclone lsf gdrive:HA-Migrate/Daily --files-only | wc -l)

    if [ "$COUNT" -gt "$GDRIVE_KEEP" ]; then

        REMOVE=$((COUNT-GDRIVE_KEEP))

        rclone lsf gdrive:HA-Migrate/Daily --files-only \
        | sort \
        | head -n "$REMOVE" \
        | while read file
        do
            echo "[DELETE] Google Drive -> $file"
            rclone delete "gdrive:HA-Migrate/Daily/$file"
        done

    fi

    echo "[OK] Google Drive retention complete."

    echo
    echo "[OK] Backup completed successfully."

else

    echo "[ERROR] Backup failed!"
    exit 1

fi
