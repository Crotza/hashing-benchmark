#!/bin/bash

# Parallel Hashing Script with Support for Multiple Algorithms
ALGORITHMS=("sha256sum" "sha512sum" "b3sum" "b2sum" "md5sum")
LOG_DIR="logs/parallel"
MASTER_LOG="logs/master_parallel_metrics.txt"
MASTER_CSV="logs/master_parallel_metrics.csv"

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: ./create_assets_parallel.sh <number_of_assets>"
  exit 1
fi

# Number of assets to create
NUM_ASSETS=$1

# Validate input
if ! [[ "$NUM_ASSETS" =~ ^[0-9]+$ ]] || [ "$NUM_ASSETS" -le 0 ]; then
  echo "Error: The number of assets must be a positive integer."
  exit 1
fi

# Create log directory
rm -rf $LOG_DIR
mkdir -p $LOG_DIR

# Initialize master logs
echo "Algorithm,Mode,Assets Processed,Success,Failures,Total Time (ms),Min Latency (ms),Max Latency (ms),Avg Latency (ms),Std Dev Latency (ms),Peak CPU (%),Avg CPU (%),Peak Mem (%),Avg Mem (%),Throughput (assets/sec)" > $MASTER_CSV
echo "Hashing Benchmark Metrics - $(date)" > $MASTER_LOG
echo "------------------------------------------------" >> $MASTER_LOG
echo "Number of Assets: $NUM_ASSETS" >> $MASTER_LOG
echo "| Algorithm | Mode       | Assets Processed | Success | Failures | Total Time (ms) | Min Latency (ms) | Max Latency (ms) | Avg Latency (ms) | Std Dev Latency (ms) | Peak CPU (%) | Avg CPU (%) | Peak Mem (%) | Avg Mem (%) | Throughput (assets/sec) |" >> $MASTER_LOG
echo "|-----------|------------|------------------|---------|----------|-----------------|------------------|------------------|------------------|----------------------|--------------|-------------|--------------|-------------|-------------------------|" >> $MASTER_LOG

# Function to calculate metrics for a specific algorithm
run_algorithm() {
  local ALGO_NAME=$1
  local CMD=$2
  local LOG_FILE="$LOG_DIR/parallel_${ALGO_NAME}_metrics.txt"

  # Initialize metrics
  SUCCESS_COUNT=0
  FAILURE_COUNT=0
  CPU_TOTAL=0
  MEM_TOTAL=0
  CPU_PEAK=0
  MEM_PEAK=0
  RESOURCE_SAMPLES=0
  LATENCIES=()

  # Clean log file
  echo "Asset Creation Log - Parallel Hashing - $(date)" > $LOG_FILE
  echo "------------------------------------------------" >> $LOG_FILE
  echo "Hashing Algorithm: $ALGO_NAME" >> $LOG_FILE
  echo "" >> $LOG_FILE

  # Start benchmarking
  START_TIME=$(date +%s%N)

  # Parallel hashing function
  create_asset() {
    local ASSET_ID=$1
    local HASH_INPUT="asset$ASSET_ID | color$ASSET_ID | $((20 + ASSET_ID)) | owner$ASSET_ID | $((100 * ASSET_ID))"

    # Start timing
    ASSET_START_TIME=$(date +%s%N)

    # Compute hash
    if HASH=$(echo -n "$HASH_INPUT" | $CMD | awk '{print $1}'); then
      echo "1" > "$LOG_DIR/status_$ASSET_ID"
    else
      echo "0" > "$LOG_DIR/status_$ASSET_ID"
      HASH="ERROR"
    fi

    # End timing
    ASSET_END_TIME=$(date +%s%N)
    ELAPSED_TIME=$((($ASSET_END_TIME - $ASSET_START_TIME) / 1000000)) # Convert to milliseconds
    echo "$ELAPSED_TIME" > "$LOG_DIR/latency_$ASSET_ID"

    # Collect system resource usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEM_USAGE=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')

    # Log the asset details
    {
      echo "Asset ID: asset$ASSET_ID"
      echo "  Hash Input: $HASH_INPUT"
      echo "  Hash: $HASH"
      echo "  Time to Hash (ms): $ELAPSED_TIME"
      echo "  CPU Usage (%): $CPU_USAGE"
      echo "  Memory Usage (%): $MEM_USAGE"
      echo "------------------------------------------------"
    } >> "$LOG_FILE"

    # Write resource usage
    echo "$CPU_USAGE $MEM_USAGE" > "$LOG_DIR/resource_$ASSET_ID"
  }

  # Run hashing tasks in parallel
  for ((i=1; i<=NUM_ASSETS; i++)); do
    create_asset "$i" &
  done
  wait

  # End benchmarking
  END_TIME=$(date +%s%N)
  TOTAL_ELAPSED_TIME=$((($END_TIME - $START_TIME) / 1000000)) # Convert to milliseconds

  # Aggregate metrics
  for FILE in $LOG_DIR/status_*; do
    if [[ $(cat "$FILE") -eq 1 ]]; then
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      FAILURE_COUNT=$((FAILURE_COUNT + 1))
    fi
  done

  for FILE in $LOG_DIR/latency_*; do
    LATENCIES+=($(cat "$FILE"))
  done

  for FILE in $LOG_DIR/resource_*; do
    RESOURCE=$(cat "$FILE")
    CPU=$(echo $RESOURCE | awk '{print $1}')
    MEM=$(echo $RESOURCE | awk '{print $2}')
    CPU_TOTAL=$(echo "$CPU_TOTAL + $CPU" | bc)
    MEM_TOTAL=$(echo "$MEM_TOTAL + $MEM" | bc)
    CPU_PEAK=$(echo "$CPU $CPU_PEAK" | awk '{print ($1 > $2) ? $1 : $2}')
    MEM_PEAK=$(echo "$MEM $MEM_PEAK" | awk '{print ($1 > $2) ? $1 : $2}')
    RESOURCE_SAMPLES=$((RESOURCE_SAMPLES + 1))
  done

  # Calculate averages and distribution metrics
  CPU_AVERAGE=$(printf "%.2f" $(echo "$CPU_TOTAL / $RESOURCE_SAMPLES" | bc -l))
  MEM_AVERAGE=$(printf "%.2f" $(echo "$MEM_TOTAL / $RESOURCE_SAMPLES" | bc -l))
  LATENCY_MIN=$(printf "%.2f" $(printf '%s\n' "${LATENCIES[@]}" | sort -n | head -n 1))
  LATENCY_MAX=$(printf "%.2f" $(printf '%s\n' "${LATENCIES[@]}" | sort -n | tail -n 1))
  LATENCY_AVG=$(printf "%.2f" $(IFS=+; echo "(${LATENCIES[*]}) / ${#LATENCIES[@]}" | bc -l))
  LATENCY_STDDEV=$(printf "%.2f" $(printf '%s\n' "${LATENCIES[@]}" | awk '{sum+=$1; sumsq+=$1*$1} END {mean=sum/NR; print sqrt(sumsq/NR - mean^2)}'))

  # Calculate throughput
  THROUGHPUT=$(printf "%.2f" $(echo "$NUM_ASSETS / ($TOTAL_ELAPSED_TIME / 1000)" | bc -l))

  # Append summary to algorithm-specific log file
  echo "Benchmark Metrics:" >> $LOG_FILE
  echo "  Total Assets Processed: $NUM_ASSETS" >> $LOG_FILE
  echo "  Success Count: $SUCCESS_COUNT" >> $LOG_FILE
  echo "  Failure Count: $FAILURE_COUNT" >> $LOG_FILE
  echo "  Total Execution Time (ms): $TOTAL_ELAPSED_TIME" >> $LOG_FILE
  echo "  Average Time per Asset (ms): $((TOTAL_ELAPSED_TIME / NUM_ASSETS))" >> $LOG_FILE
  echo "  Resource Usage:" >> $LOG_FILE
  echo "    Peak CPU Usage (%): $CPU_PEAK" >> $LOG_FILE
  echo "    Average CPU Usage (%): $CPU_AVERAGE" >> $LOG_FILE
  echo "    Peak Memory Usage (%): $MEM_PEAK" >> $LOG_FILE
  echo "    Average Memory Usage (%): $MEM_AVERAGE" >> $LOG_FILE
  echo "  Latency Distribution (ms):" >> $LOG_FILE
  echo "    Minimum: $LATENCY_MIN" >> $LOG_FILE
  echo "    Maximum: $LATENCY_MAX" >> $LOG_FILE
  echo "    Average: $LATENCY_AVG" >> $LOG_FILE
  echo "    Std Dev: $LATENCY_STDDEV" >> $LOG_FILE
  echo "  Throughput (assets/second): $THROUGHPUT" >> $LOG_FILE
  echo "------------------------------------------------" >> $LOG_FILE

  # Append summary to master logs
  echo "| $ALGO_NAME | parallel | $NUM_ASSETS | $SUCCESS_COUNT | $FAILURE_COUNT | $TOTAL_ELAPSED_TIME ms | $LATENCY_MIN ms | $LATENCY_MAX ms | $LATENCY_AVG ms | $LATENCY_STDDEV ms | $CPU_PEAK | $CPU_AVERAGE | $MEM_PEAK | $MEM_AVERAGE | $THROUGHPUT |" >> $MASTER_LOG
  echo "$ALGO_NAME,parallel,$NUM_ASSETS,$SUCCESS_COUNT,$FAILURE_COUNT,$TOTAL_ELAPSED_TIME,$LATENCY_MIN,$LATENCY_MAX,$LATENCY_AVG,$LATENCY_STDDEV,$CPU_PEAK,$CPU_AVERAGE,$MEM_PEAK,$MEM_AVERAGE,$THROUGHPUT" >> $MASTER_CSV

  echo "     📊 Parallel hashing for $ALGO_NAME completed. Check '$LOG_FILE' for details."

  # Cleanup temporary files
  rm -f $LOG_DIR/status_* $LOG_DIR/latency_* $LOG_DIR/resource_*
}

# Run all algorithms
for ALGO in "${ALGORITHMS[@]}"; do
  case $ALGO in
    "sha256sum") run_algorithm "sha256" "$ALGO" ;;
    "sha512sum") run_algorithm "sha512" "$ALGO" ;;
    "b3sum") run_algorithm "blake3" "$ALGO" ;;
    "b2sum") run_algorithm "blake2b" "$ALGO" ;;
    "md5sum") run_algorithm "md5" "$ALGO" ;;
    *) echo "Unsupported algorithm: $ALGO" ;;
  esac
done

# Notify user
echo "     ✅ All algorithms completed. Check '$MASTER_LOG' for the summary of results."