#!/usr/bin/env bash
# Runs as the ssh_username user (ubuntu). Use sudo for privileged steps.
set -euo pipefail

echo "Updating package lists..."
sudo apt-get update

echo "Installing base packages..."
sudo apt-get install -y curl unzip nginx

echo "Enabling nginx..."
sudo systemctl enable nginx

echo "Setup script finished."
