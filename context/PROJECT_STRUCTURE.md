# Hyte Y70 Touch-Infinite Display Project Structure

## Directory Layout

```
hyte-touch-infinite-flakes/
├── flake.nix                    # Main Nix flake configuration
├── configuration.nix            # NixOS system configuration
├── context/                     # Project documentation and context
│   ├── PROJECT_REQUIREMENTS.md  # Original user requirements
│   └── PROJECT_STRUCTURE.md     # This file
├── modules/                     # Custom NixOS modules
│   └── hyte-touch.nix           # Main touch display module
├── home/                        # Home-manager configurations
│   └── touchdisplay.nix         # Config for locked-down touch user
├── packages/                    # Custom Nix packages
│   ├── touch-widgets.nix        # Quickshell widget package
│   └── system-monitor.nix       # System monitoring utilities
├── config/                      # Configuration files
│   └── quickshell/              # Quickshell widget configurations
│       ├── touch-config.qml     # Main touch interface config
│       └── widgets/             # Individual widget components
│           ├── TemperatureWidget.qml
│           ├── SystemUsageWidget.qml
│           └── UsageBar.qml
└── scripts/                     # Monitoring scripts
    ├── monitor-temps.sh         # Temperature monitoring
    └── monitor-usage.sh         # System usage monitoring
```

## Key Components

1. **Display Isolation**: Prevents main Hyprland from grabbing touch display
2. **Locked User**: Creates `touchdisplay` user with no shell access
3. **Auto-start**: Wayland session starts automatically on touch display
4. **Touch Interface**: Quickshell-based widget system with swipe/tap support
5. **System Monitoring**: Real-time temperature and usage monitoring
6. **Customization**: Configurable dimming and widget settings

## Usage

1. Adjust `displayOutput` in `configuration.nix` to match your touch display
2. Build with: `nixos-rebuild switch --flake .#hyte-system`
3. The touch display will automatically start the widget interface
4. Main displays remain under your normal Hyprland control
