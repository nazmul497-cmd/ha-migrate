#!/bin/bash

echo "================================="
echo "      HA-Migrate Doctor"
echo "================================="
echo

# Check Docker
if command -v docker >/dev/null 2>&1; then
    echo "[OK] Docker installed"
else
    echo "[ERROR] Docker not installed"
fi

# Check Home Assistant container
if sudo docker ps -a --format "{{.Names}}" | grep -q "^homeassistant$"; then
    echo "[OK] Home Assistant container found"
else
    echo "[ERROR] Home Assistant container not found"
fi

# Detect Config Path
CONFIG_PATH=$(sudo docker inspect homeassistant --format '{{range .Mounts}}{{.Source}}{{end}}' 2>/dev/null)

if [ -n "$CONFIG_PATH" ]; then
    echo "[OK] Config Path: $CONFIG_PATH"
else
    echo "[ERROR] Config path not found"
fi
