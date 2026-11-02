#!/bin/bash

# Resolve project directory and log file path
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/monitor.log"
LOGGING_FAILED=0

if ! mkdir -p "$PROJECT_DIR/logs"; then
    echo "ERROR: Unable to create the logs directory." >&2
    LOGGING_FAILED=1
fi

log_warning() {
    local message="$1"

    if ! printf '%s: WARNING - %s\n' "$(date)" "$message" >> "$LOG_FILE"; then
        echo "ERROR: Unable to write warning to $LOG_FILE" >&2
        LOGGING_FAILED=1
    fi
}

# Cloud Monitoring & Incident Lab
# Monitor CPU, memory, and disk usage
# Optional test mode:
# $1 = simulated disk usage percentage
# $2 = simulated CPU usage percentage
# $3 = simulated memory unavailable percentage
if [ -n "$1" ]; then
    if ! [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]] || awk "BEGIN {exit !($1 > 100)}"; then
        echo "ERROR: Disk usage must be a number between 0 and 100."
        exit 1
    fi
    DISK_USAGE="$1"
else
    DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
fi
# Calculate CPU usage percentage
if [ -n "$2" ]; then
    if ! [[ "$2" =~ ^[0-9]+([.][0-9]+)?$ ]] || awk "BEGIN {exit !($2 > 100)}"; then
        echo "ERROR: CPU usage must be a number between 0 and 100."
        exit 1
    fi
    CPU_USAGE="$2"
else
    CPU_USAGE=$(top -bn1 | awk -F'[, ]+' '/Cpu\(s\)/ {for(i=1;i<=NF;i++) if($i=="id") printf "%.1f",100-$(i-1)}')
fi
# Estimate memory pressure using available memory
if [ -n "$3" ]; then
    if ! [[ "$3" =~ ^[0-9]+([.][0-9]+)?$ ]] || awk "BEGIN {exit !($3 > 100)}"; then
        echo "ERROR: Memory usage must be a number between 0 and 100."
        exit 1
    fi
    MEMORY_USAGE="$3"
else
    MEMORY_USAGE=$(free -b | awk '/^Mem:/ {printf "%.1f", (1 - $7/$2) * 100}')
fi
# Validate collected system readings
for METRIC in DISK_USAGE CPU_USAGE MEMORY_USAGE; do
    VALUE="${!METRIC}"
    if ! [[ "$VALUE" =~ ^[0-9]+([.][0-9]+)?$ ]] || awk "BEGIN {exit !($VALUE > 100)}"; then
        echo "ERROR: Unable to collect a valid $METRIC reading."
        exit 1
    fi
done

echo "================================"
echo "   SYSTEM MONITORING REPORT"
echo "================================"

echo "Date: $(date)"
echo

echo "CPU Usage:"
echo "CPU usage percentage: ${CPU_USAGE}%"
if ! top -bn1 | grep "Cpu(s)"; then
    echo "NOTICE: Live CPU details unavailable; using the collected CPU percentage above."
fi
if awk "BEGIN {exit !($CPU_USAGE >= 80)}"; then
    echo "WARNING: CPU usage is at or above 80%!"
    log_warning "CPU usage is ${CPU_USAGE}%"
else
    echo "OK: CPU usage is below 80%."
fi

echo "Memory Availability:"
echo "Memory unavailable percentage (based on available memory): ${MEMORY_USAGE}%"
free -h

if awk "BEGIN {exit !($MEMORY_USAGE >= 80)}"; then
    echo "WARNING: Memory unavailable is at or above 80%!"
    log_warning "Memory unavailable is ${MEMORY_USAGE}%"
else
    echo "OK: Memory unavailable is below 80%."
fi
echo

echo "Disk Usage:"
df -h /
echo "Disk usage percentage: ${DISK_USAGE}%"
if awk "BEGIN {exit !($DISK_USAGE >= 80)}"; then
    echo "WARNING: Disk usage is at or above 80%!"
    log_warning "Disk usage is ${DISK_USAGE}%"
else
    echo "OK: Disk usage is below 80%."
fi

if [ "$LOGGING_FAILED" -ne 0 ]; then
    exit 1
fi
