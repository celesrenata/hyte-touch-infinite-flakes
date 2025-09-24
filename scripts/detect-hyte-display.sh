#!/usr/bin/env bash

# Dynamic Hyte touch display detection script
# Identifies the display by its unique resolution characteristics

detect_hyte_display() {
    # Look for displays with the characteristic tall rectangle resolution
    for card in /sys/class/drm/card*-DP-*; do
        if [[ -f "$card/status" && "$(cat "$card/status")" == "connected" ]]; then
            if [[ -f "$card/modes" ]]; then
                # Check for the characteristic Hyte display resolutions
                if grep -q "2560x682\|3840x1100" "$card/modes"; then
                    basename "$card" | sed 's/card[0-9]*-//'
                    return 0
                fi
            fi
        fi
    done
    
    # Fallback: look for USB display device with vendor ID 264A:233C
    if lsusb | grep -q "264a:233c"; then
        # If USB device is present, try to find corresponding DRM output
        for card in /sys/class/drm/card*-DP-*; do
            if [[ -f "$card/status" && "$(cat "$card/status")" == "connected" ]]; then
                basename "$card" | sed 's/card[0-9]*-//'
                return 0
            fi
        done
    fi
    
    return 1
}

detect_hyte_touch_device() {
    # Look for the specific USB touch device
    find /dev/input/by-id/ -name "*264A*233C*" 2>/dev/null | head -1
}

case "${1:-display}" in
    "display")
        detect_hyte_display
        ;;
    "touch")
        detect_hyte_touch_device
        ;;
    "both")
        echo "Display: $(detect_hyte_display)"
        echo "Touch: $(detect_hyte_touch_device)"
        ;;
esac
