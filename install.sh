#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"

show_banner() {
clear
echo "=========================================="
echo "         HA-Migrate Installer"
echo "              Version 2.0"
echo "=========================================="
echo
}

check_os() {
echo "[INFO] Checking operating system..."

if [ ! -f /etc/os-release ]; then
    echo "[ERROR] Unsupported operating system."
    exit 1
fi

source /etc/os-release

if [ "$ID" != "ubuntu" ]; then
    echo "[ERROR] Only Ubuntu is supported."
    exit 1
fi

echo "[ OK ] Ubuntu detected."
echo
}

check_dependencies() {

echo "[INFO] Checking dependencies..."

for cmd in git docker tar rclone; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[ OK ] $cmd"
    else
        echo "[ERROR] $cmd is not installed."
        exit 1
    fi
done

echo
}

create_directories() {

echo "[INFO] Creating directories..."

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

echo "[ OK ] backups/"
echo "[ OK ] logs/"
echo
}

set_permissions() {

echo "[INFO] Setting permissions..."

chmod +x "$PROJECT_DIR/backup.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/restore.sh" 2>/dev/null || true

echo "[ OK ] backup.sh"
echo "[ OK ] restore.sh"
echo
}

setup_cron() {

echo "[INFO] Checking cron..."

CRON_JOB="0 2 * * * $PROJECT_DIR/backup.sh >> $PROJECT_DIR/backup.log 2>&1"

(crontab -l 2>/dev/null | grep -F "$PROJECT_DIR/backup.sh") >/dev/null \
&& echo "[ OK ] Cron already exists." \
|| (
    (crontab -l 2>/dev/null
    echo "$CRON_JOB") | crontab -
    echo "[ OK ] Cron installed."
)

echo
}

show_summary() {

echo "=========================================="
echo " Installation Completed Successfully"
echo "=========================================="
echo
echo "Project Folder : $PROJECT_DIR"
echo "Backup Folder  : $BACKUP_DIR"
echo "Logs Folder    : $LOG_DIR"
echo
echo "Daily Backup : 02:00 AM"
echo
echo "Next Step:"
echo "Run:"
echo "./backup.sh"
echo
}

main() {

show_banner
check_os
check_dependencies
create_directories
set_permissions
setup_cron
show_summary

}

main
