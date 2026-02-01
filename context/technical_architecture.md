# Technical Architecture

## NixOS Flake Structure

### Core Components
- **flake.nix**: Main flake definition with inputs (nixpkgs, home-manager, hyprland, quickshell)
- **configuration.nix**: Base NixOS system configuration
- **modules/hyte-touch.nix**: Custom NixOS module for isolated Cage session
- **packages/start-hyte-touch.nix**: Startup script package

### Display Isolation System
- **Main Session**: Hyprland excludes DP-3 via config snippet
- **Touch Session**: Cage compositor runs on DP-3 only
- **Input Mapping**: Touchscreen disabled in main session, active in Cage

### Service Architecture
1. **systemd user service**: `hyte-touch-display.service` manages Cage session
2. **Auto-detection**: Dynamically finds DP-3 and correct DRM device
3. **Restart policy**: Automatic restart on failure

### Compositor Choice
- **Cage**: Minimal Wayland kiosk compositor (single fullscreen app)
- **Benefits**: Lightweight, no window management overhead, perfect for dedicated display
- **Alternative**: Could use Weston for more features

## Widget System

### QuickShell Integration
- **Framework**: QuickShell (Qt-based shell framework)
- **Configuration**: QML-based widget definitions in config/quickshell/
- **Widgets**: Temperature graphs, system usage, music visualizer

### Touch Input Handling
- **Input mapping**: Touch device automatically mapped to Cage output
- **Isolation**: Touchscreen disabled in main Hyprland session
- **Gesture support**: Swipe navigation between widget pages

## Configuration Files
- **Hyprland exclusion**: `config/hyprland-exclude-dp3.conf`
- **QuickShell config**: `config/quickshell/shell.qml`
- **Startup script**: `packages/start-hyte-touch.nix`
