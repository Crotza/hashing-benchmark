#!/bin/bash

# Cleanup Script for Hashing Benchmark Project
# Removes logs, plots, temporary files, and shuts down the Fabric network.

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOGS_DIR="$BASE_DIR/bash_scripts/logs"
PLOTS_DIR="$BASE_DIR/bash_scripts/plots"
FABRIC_DIR="$BASE_DIR/../hashing-benchmark-project" 

echo "🧹 Starting Cleanup..."

# 1. Stop and bring down the Hyperledger Fabric Network
echo "🚫 Bringing down the Hyperledger Fabric Network..."
if [ -d "$FABRIC_DIR" ]; then
  cd "$FABRIC_DIR" || exit
  ./network.sh down
  cd - > /dev/null
else
  echo "⚠️ Fabric network directory not found: $FABRIC_DIR. Skipping..."
fi

# 2. Remove Logs
if [ -d "$LOGS_DIR" ]; then
  echo "🗑 Removing logs directory: $LOGS_DIR"
  rm -rf "$LOGS_DIR"
else
  echo "✅ No logs directory found. Skipping..."
fi

# 3. Remove Plots
if [ -d "$PLOTS_DIR" ]; then
  echo "🗑 Removing plots directory: $PLOTS_DIR"
  rm -rf "$PLOTS_DIR"
else
  echo "✅ No plots directory found. Skipping..."
fi

# 4. Remove Temporary Files
echo "🧹 Removing any temporary files..."
find "$BASE_DIR" -type f -name "*~" -exec rm -f {} \;
find "$BASE_DIR" -type f -name "*.tmp" -exec rm -f {} \;

# 5. Confirmation
echo "✅ Cleanup Complete! Logs, plots, and temporary files have been removed."
echo "🚀 You can now start fresh by running the network and benchmark scripts."