# Hardware Compatibility

## Supported Devices

### Primary Target: Hyte Y70 Touch-Infinite
- **Product**: Hyte Y70 Touch-Infinite Display
- **USB ID**: 264a:233c
- **Description**: "Thermaltake 2.1 inch Round TFT LCD Display Module-B"
- **Manufacturer**: HKC OVERSEAS LIMITED
- **Resolution**: 2560x682 or 3840x1100 pixels
- **Interface**: DisplayPort + USB touch

### Detection Criteria
The system identifies compatible displays by:
1. **Resolution matching**: 2560x682 or 3840x1100 modes
2. **USB device presence**: Vendor ID 264a, Product ID 233c
3. **DisplayPort connection**: Connected DRM output

## Hardware Requirements

### System Requirements
- **OS**: NixOS with Wayland support
- **GPU**: Any GPU with DisplayPort output
- **USB**: Available USB port for touch input
- **Memory**: Minimal additional RAM usage
- **Storage**: ~500MB for packages and configuration

### Graphics Compatibility
- **Intel**: Integrated graphics supported
- **NVIDIA**: Full support with proprietary drivers
- **AMD**: Full support with open-source drivers
- **Multiple GPUs**: Automatic detection across all cards

## Connection Setup

### Physical Connections
1. **DisplayPort**: Connect display to GPU DisplayPort output
2. **USB**: Connect touch interface to any USB port
3. **Power**: Usually powered via DisplayPort or separate power

### Display Configuration
- **Auto-detection**: System automatically finds and configures display
- **Exclusion**: Main desktop (Hyprland) excludes the touch display
- **Isolation**: Touch display runs separate Sway session

## Troubleshooting Hardware Issues

### Display Not Detected
```bash
# Check physical connection
ls /sys/class/drm/card*-DP-*/status
cat /sys/class/drm/card*-DP-*/status

# Check available modes
cat /sys/class/drm/card*-DP-*/modes | grep -E "2560x682|3840x1100"
```

### Touch Input Not Working
```bash
# Check USB device
lsusb | grep 264a:233c

# Check input devices
ls /dev/input/by-id/*264A*233C*
```

### Multiple Display Issues
- System handles multiple GPUs automatically
- Each DRM card is checked for compatible displays
- First detected compatible display is used

## Future Compatibility
The detection system is designed to be extensible for:
- Other Hyte display models
- Similar touch displays with different resolutions
- USB displays with touch capability
