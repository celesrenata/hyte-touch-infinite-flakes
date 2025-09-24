#!/usr/bin/env bash

# Temperature monitoring script for Hyte touch display
# Outputs JSON format for consumption by Quickshell widgets

get_cpu_temp() {
    sensors | grep -A 3 "coretemp" | grep "Core 0" | awk '{print $3}' | sed 's/+//;s/°C//' | head -1
}

get_gpu_temp() {
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0"
}

get_ambient_temp() {
    # Try to get ambient temperature from available sensors
    sensors | grep -i "ambient\|case" | awk '{print $2}' | sed 's/+//;s/°C//' | head -1 || echo "25"
}

# Output JSON format
cat << EOF
{
    "cpu": $(get_cpu_temp),
    "gpu": $(get_gpu_temp),
    "ambient": $(get_ambient_temp),
    "timestamp": $(date +%s)
}
EOF
