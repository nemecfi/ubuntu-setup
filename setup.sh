#!/usr/bin/env bash
# Bootstrap script for a fresh Ubuntu 26 LTS install.
# This script orchestrates the setup by calling modular sub-scripts.

set -e

# Path to this script's directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Log all output to setup.log
exec > >(tee -a "$SCRIPT_DIR/setup.log") 2>&1

echo "==========================================="
echo " STARTING UBUNTU SETUP"
echo "==========================================="

# Ensure scripts are executable
chmod +x "$SCRIPT_DIR"/scripts/*.sh

# Run sub-scripts in order
bash "$SCRIPT_DIR/scripts/01-debloat-and-perf.sh"
bash "$SCRIPT_DIR/scripts/02-install-packages.sh"
bash "$SCRIPT_DIR/scripts/03-configure-system.sh"

echo ""
echo "==========================================="
echo " ALL PHASES COMPLETE"
echo " Open a new shell or run: source ~/.bashrc"
echo "==========================================="
