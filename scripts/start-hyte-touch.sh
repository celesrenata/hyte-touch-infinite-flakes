#!/usr/bin/env bash
# Start Cage compositor on DP-3 with QuickShell

# Find DP-3 connector
DP3_CONNECTOR=$(ls /sys/class/drm/ | grep -E "card[0-9]+-DP-3$" | head -1)
if [ -z "$DP3_CONNECTOR" ]; then
    echo "DP-3 not found"
    exit 1
fi

# Extract card number
CARD_NUM=$(echo "$DP3_CONNECTOR" | grep -oP 'card\K[0-9]+')

# Set environment for specific output
export WLR_DRM_DEVICES="/dev/dri/card${CARD_NUM}"
export WLR_DRM_NO_MODIFIERS=1

# Find touchscreen device
TOUCH_DEVICE=$(libinput list-devices | grep -A 10 "ilitek" | grep "Kernel:" | awk '{print $2}')

# Map touch to output
if [ -n "$TOUCH_DEVICE" ]; then
    export LIBINPUT_CALIBRATION_MATRIX="1 0 0 0 1 0"
fi

# Start Cage with QuickShell
exec cage -d -s -- quickshell -c @QUICKSHELL_CONFIG@
