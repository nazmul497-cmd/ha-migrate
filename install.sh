#!/bin/bash

echo "========================================"
echo "        HA-Migrate Installer"
echo "========================================"

echo ""
echo "Updating package list..."
sudo apt update

echo ""
echo "Installing required packages..."
sudo apt install -y docker.io docker-compose-plugin git curl unzip

echo ""
echo "Creating Home Assistant directory..."
mkdir -p ~/homeassistant

echo ""
echo "Installation completed successfully!"
