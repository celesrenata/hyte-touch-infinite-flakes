# Hyte Touch Display - Isolated Session Setup

## Overview
This configuration creates an isolated Cage compositor session for the Hyte Y70 Touch display (DP-3), separate from your main Hyprland session.

## How It Works

1. **Main Hyprland Session**: Add to your Hyprland config:
   ```
   source = /path/to/config/hyprland-exclude-dp3.conf
   ```
   This disables DP-3 and the touchscreen in your main session.

2. **Isolated Touch Session**: A systemd user service runs Cage compositor on DP-3 only, displaying QuickShell widgets.

3. **Input Isolation**: Touchscreen input only affects the Cage session, mouse cannot enter DP-3.

## Installation

### For NixOS System Configuration:
```nix
{
  imports = [ ./modules/hyte-touch.nix ];
  services.hyte-touch.enable = true;
}
```

### For Existing Hyprland Setup:
Add to your `~/.config/hypr/hyprland.conf`:
```
source = /path/to/hyte-touch-infinite-flakes/config/hyprland-exclude-dp3.conf
```

Then enable the user service:
```bash
systemctl --user enable hyte-touch-display.service
systemctl --user start hyte-touch-display.service
```

## Manual Testing
```bash
# Test the startup script
start-hyte-touch

# Check service status
systemctl --user status hyte-touch-display.service

# View logs
journalctl --user -u hyte-touch-display.service -f
```

## Architecture
- **Compositor**: Cage (minimal Wayland kiosk compositor)
- **UI**: QuickShell (QML-based touch interface)
- **Display**: DP-3 only (auto-detected)
- **Input**: Touchscreen mapped exclusively to this session
