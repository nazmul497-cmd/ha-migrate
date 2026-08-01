#!/bin/bash

echo "================================="
echo "      HA-Migrate Update"
echo "================================="
echo

PROJECT_DIR="$HOME/ha-migrate"

if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "[ERROR] Git repository not found!"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

echo "[INFO] Checking for local changes..."
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "[WARN] You have uncommitted changes."
    read -p "Continue update anyway? (y/n): " ans
    if [ "$ans" != "y" ]; then
        echo "Update cancelled."
        exit 0
    fi
fi

echo
echo "[INFO] Pulling latest version from GitHub..."
git pull

echo
echo "[INFO] Fixing permissions..."
chmod +x *.sh ha-migrate 2>/dev/null

echo
echo "[OK] HA-Migrate updated successfully!"
