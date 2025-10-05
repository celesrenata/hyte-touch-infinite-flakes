# Technical Architecture

## NixOS Flake Structure

### Core Components
- **flake.nix**: Main flake definition with inputs (nixpkgs, home-manager, hyprland, quickshell)
- **configuration.nix**: Base NixOS system configuration
- **modules/hyte-touch.nix**: Custom NixOS module for Hyte display management
- **home/touchdisplay.nix**: Home-manager configuration for touch display user

### Display Detection System
```bash
# Detection script logic
for card in /sys/class/drm/card*-DP-*; do
    if grep -q "2560x682\|3840x1100" "$card/modes"; then
        # Found Hyte display
    fi
done
```

### Service Architecture
1. **hyprland-exclude-hyte.service**: Excludes Hyte display from main desktop
2. **touchdisplay-session.service**: Manages dedicated Sway session for touch display
3. **Auto-detection**: Dynamic display identification at boot

### User Isolation
- **touchdisplay user**: System user (UID 999) for display session
- **Separate runtime**: `/run/user/999` for isolated session
- **Security**: No keybindings, limited system access

## Widget System

### QuickShell Integration
- **Framework**: QuickShell (Qt-based shell framework)
- **Configuration**: QML-based widget definitions
- **Widgets**: Temperature graphs, system usage, music visualizer, backgrounds

### Touch Input Handling
- **Input mapping**: Touch device mapped to Hyte display output
- **Gesture support**: Swipe navigation between widget pages
- **Settings**: Configurable sensitivity and timeouts

## Package Management
- **Custom packages**: system-monitor, touch-widgets
- **Dependencies**: lm_sensors, procps, nvidia-system-monitor-qt
- **Build system**: Nix derivations with proper wrapping

## Configuration Files
- **Sway config**: `/etc/sway/touchdisplay.conf`
- **QuickShell config**: `/etc/quickshell/touch-config.qml`
- **Settings**: JSON-based configuration in user home
