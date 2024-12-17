#!/bin/bash

# Variables
SEQUENTIAL_SCRIPT="create_assets_sequential.sh"
PARALLEL_SCRIPT="create_assets_parallel.sh"
PLOT_SCRIPT="plot_results.py"
LOGS_DIR="logs"
PLOTS_DIR="plots"
NUM_ASSETS=1000
PYTHON_EXEC="python3"

# Step 1: Ensure Scripts Have Execute Permissions
echo "🔧 Ensuring scripts have execute permissions..."
chmod +x $SEQUENTIAL_SCRIPT
chmod +x $PARALLEL_SCRIPT

# Step 2: Run Sequential Asset Creation Script
echo "🚀 Running Sequential Asset Creation..."
./$SEQUENTIAL_SCRIPT $NUM_ASSETS
if [ $? -ne 0 ]; then
  echo "❌ Error running $SEQUENTIAL_SCRIPT. Exiting."
  exit 1
fi

# Step 3: Run Parallel Asset Creation Script
echo "🚀 Running Parallel Asset Creation..."
./$PARALLEL_SCRIPT $NUM_ASSETS
if [ $? -ne 0 ]; then
  echo "❌ Error running $PARALLEL_SCRIPT. Exiting."
  exit 1
fi

# Step 4: Run Python Script to Generate Plots
echo "📊 Generating plots with Python..."
$PYTHON_EXEC $PLOT_SCRIPT
if [ $? -ne 0 ]; then
  echo "❌ Error running $PLOT_SCRIPT. Exiting."
  exit 1
fi

# Step 5: Summarize Output Files
echo "✅ Benchmarking and Plots Completed Successfully!"
echo "🔍 Check the following generated outputs:"
echo "  - Logs Directory: $LOGS_DIR"
echo "  - Plots Directory: $PLOTS_DIR"