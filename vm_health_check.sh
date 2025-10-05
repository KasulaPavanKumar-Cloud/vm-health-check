#!/bin/bash

THRESHOLD=60
EXPLAIN_MODE=false

if [ "$1" == "explain" ]; then
    EXPLAIN_MODE=true
fi

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
}

get_memory_usage() {
    free | grep Mem | awk '{printf "%.0f", ($3/$2) * 100}'
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1
}

CPU_USAGE=$(get_cpu_usage)
MEMORY_USAGE=$(get_memory_usage)
DISK_USAGE=$(get_disk_usage)

CPU_USAGE_INT=${CPU_USAGE%.*}
MEMORY_USAGE_INT=${MEMORY_USAGE%.*}
DISK_USAGE_INT=${DISK_USAGE%.*}

IS_HEALTHY=true
REASONS=()

if [ "$CPU_USAGE_INT" -gt "$THRESHOLD" ]; then
    IS_HEALTHY=false
    REASONS+=("CPU usage is ${CPU_USAGE_INT}% (exceeds ${THRESHOLD}% threshold)")
fi

if [ "$MEMORY_USAGE_INT" -gt "$THRESHOLD" ]; then
    IS_HEALTHY=false
    REASONS+=("Memory usage is ${MEMORY_USAGE_INT}% (exceeds ${THRESHOLD}% threshold)")
fi

if [ "$DISK_USAGE_INT" -gt "$THRESHOLD" ]; then
    IS_HEALTHY=false
    REASONS+=("Disk usage is ${DISK_USAGE_INT}% (exceeds ${THRESHOLD}% threshold)")
fi

if [ "$IS_HEALTHY" = true ]; then
    echo "VM Health Status: Healthy"
    if [ "$EXPLAIN_MODE" = true ]; then
        echo ""
        echo "Reasons:"
        echo "- CPU usage: ${CPU_USAGE_INT}% (below ${THRESHOLD}% threshold)"
        echo "- Memory usage: ${MEMORY_USAGE_INT}% (below ${THRESHOLD}% threshold)"
        echo "- Disk usage: ${DISK_USAGE_INT}% (below ${THRESHOLD}% threshold)"
    fi
else
    echo "VM Health Status: Not Healthy"
    if [ "$EXPLAIN_MODE" = true ]; then
        echo ""
        echo "Reasons:"
        for reason in "${REASONS[@]}"; do
            echo "- $reason"
        done
        if [ "$CPU_USAGE_INT" -le "$THRESHOLD" ]; then
            echo "- CPU usage: ${CPU_USAGE_INT}% (below ${THRESHOLD}% threshold) ✓"
        fi
        if [ "$MEMORY_USAGE_INT" -le "$THRESHOLD" ]; then
            echo "- Memory usage: ${MEMORY_USAGE_INT}% (below ${THRESHOLD}% threshold) ✓"
        fi
        if [ "$DISK_USAGE_INT" -le "$THRESHOLD" ]; then
            echo "- Disk usage: ${DISK_USAGE_INT}% (below ${THRESHOLD}% threshold) ✓"
        fi
    fi
fi
