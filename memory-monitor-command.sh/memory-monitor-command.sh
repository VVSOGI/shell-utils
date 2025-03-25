#!/bin/bash

show_usage() {
    echo "================ How to use ============================"
    echo "      $0 <Command>                          "
    echo "      Examle: $0 yarn next build            "
    echo "      $0 npm run test                       "
    echo "      $0 node heavy-process.js              "
    echo "========================================================"
    exit 1
}

if [ $# -eq 0 ]; then
  show_usage
  exit 1
fi

COMMAND="$@"
COMMAND_NAME=$(echo "$COMMAND" | awk '{print $1}')

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="memory_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${COMMAND_NAME}_${TIMESTAMP}.log"

monitor_memory() {
  while true; do
    TOTAL=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
    FREE=$(grep 'MemFree' /proc/meminfo | awk '{print $2}')
    AVAIL=$(grep 'MemAvailable' /proc/meminfo | awk '{print $2}')
    BUFFERS=$(grep 'Buffers' /proc/meminfo | awk '{print $2}')
    CACHED=$(grep 'Cached' /proc/meminfo | awk '{print $2}' | head -1)
    
    TOTAL_MB=$(echo "scale=2; $TOTAL/1024" | bc)
    FREE_MB=$(echo "scale=2; $FREE/1024" | bc)
    AVAIL_MB=$(echo "scale=2; $AVAIL/1024" | bc)
    BUFFERS_MB=$(echo "scale=2; $BUFFERS/1024" | bc)
    CACHED_MB=$(echo "scale=2; $CACHED/1024" | bc)
    BUFFER_CACHE_MB=$(echo "scale=2; $BUFFERS_MB + $CACHED_MB" | bc)
    USED_MB=$(echo "scale=2; $TOTAL_MB - $FREE_MB - $BUFFER_CACHE_MB" | bc)
    
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo -e "\033[2K\r[$TIMESTAMP] Total: ${TOTAL_MB}MB | Free: ${FREE_MB}MB | Available: ${AVAIL_MB}MB | Used: ${USED_MB}MB | Buffer/Cache: ${BUFFER_CACHE_MB}MB" >> "$LOG_FILE"
    echo -e "\033[2K\r[$TIMESTAMP] Total: ${TOTAL_MB}MB | Free: ${FREE_MB}MB | Available: ${AVAIL_MB}MB | Used: ${USED_MB}MB | Buffer/Cache: ${BUFFER_CACHE_MB}MB"
    sleep 1
  done
}

MAX_USED=0
MAX_USED_TIMESTAMP=""

monitor_memory &
MONITOR_PID=$!

echo "Executing command: $COMMAND"
echo "Memory usage is logged to $LOG_FILE"

START_TIME=$(date +%s)
eval $COMMAND
EXIT_CODE=$?

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

kill $MONITOR_PID

MAX_USED=$(awk -F, 'NR>1 {if($5>max) {max=$5; timestamp=$1}} END {print max}' "$LOG_FILE")
MAX_USED_TIMESTAMP=$(awk -F, 'NR>1 {if($5>max) {max=$5; timestamp=$1}} END {print timestamp}' "$LOG_FILE")

echo ""
echo "================ RESULT ================"
echo "Command: $COMMAND"
echo "Exit Code: $EXIT_CODE"
echo "Execution Time: $(printf '%02d:%02d: %02d' $((ELAPSED/3600)) $((ELAPSED%3600/60)) $((ELAPSED%60))))"
echo "Maximum memory usage: ${MAX_USED}MB (at ${MAX_USED_TIMESTAMP})"
echo "Memory usage log: $LOG_FILE"
echo "======================================="
