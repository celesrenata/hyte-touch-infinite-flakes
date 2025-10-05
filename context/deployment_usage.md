# Deployment and Usage

## Installation

### NixOS System Deployment
```bash
# Clone repository
git clone <repo-url> hyte-touch-infinite-flakes
cd hyte-touch-infinite-flakes

# Build and switch to configuration
sudo nixos-rebuild switch --flake .#hyte-system
```

### Module Integration
```nix
# In existing NixOS configuration
{
  imports = [ ./hyte-touch-infinite-flakes/modules/hyte-touch.nix ];
  
  services.hyte-touch.enable = true;
}
```

## Hardware Requirements
- Hyte Y70 case with Touch-Infinite display
- DisplayPort connection to GPU
- USB connection for touch input
- NixOS system with Wayland support

## Service Management

### Check Status
```bash
# Check display detection
systemctl status hyprland-exclude-hyte.service

# Check touch session
systemctl status touchdisplay-session.service

# Manual display detection
/run/current-system/sw/bin/detect-hyte-display.sh
```

### Troubleshooting
```bash
# Check display connection
cat /sys/class/drm/card*/status

# Check available modes
cat /sys/class/drm/card*/modes

# Check USB touch device
lsusb | grep 264a:233c
```

## Widget Configuration

### Available Widgets
- **Temperature Monitor**: CPU/GPU temperature graphs
- **System Usage**: CPU, memory, disk usage
- **Music Visualizer**: Audio-reactive display
- **Background Changer**: Dynamic wallpaper rotation

### Customization
Edit `/var/lib/touchdisplay/.config/touch-display/settings.json`:
```json
{
  "dimming": {
    "enabled": true,
    "timeout": 30
  },
  "widgets": {
    "temperature_graph": true,
    "system_usage": true,
    "music_visualizer": true
  }
}
```

## Security Considerations
- Touch display runs as isolated system user
- No keyboard shortcuts or system access
- Separate Wayland session from main desktop
- Limited package access and permissions
