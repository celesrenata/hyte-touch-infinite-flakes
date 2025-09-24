#!/usr/bin/env bash

# System usage monitoring script for Hyte touch display
# Outputs JSON format for consumption by Quickshell widgets

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
}

get_ram_usage() {
    free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
}

get_gpu_usage() {
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0"
}

get_disk_usage() {
    df -h | grep -E '^/dev/' | awk '{print "\"" $6 "\": " $5}' | sed 's/%//' | paste -sd ','
}

# Output JSON format
cat << EOF
{
    "cpu": $(get_cpu_usage),
    "ram": $(get_ram_usage),
    "gpu": $(get_gpu_usage),
    "disks": { $(get_disk_usage) },
    "timestamp": $(date +%s)
}
EOF
