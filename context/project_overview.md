# Hyte Y70 Touch-Infinite Display Configuration

## Project Purpose
NixOS flake configuration for the Hyte Y70 Touch-Infinite display - a secondary touch display panel commonly found in Hyte PC cases. This project provides a complete NixOS system configuration to drive the touch display with custom widgets and system monitoring.

## Hardware Target
- **Device**: Hyte Y70 Touch-Infinite Display
- **USB ID**: 264a:233c (Thermaltake 2.1" Round TFT LCD)
- **Resolution**: 2560x682 or 3840x1100 (tall rectangle format)
- **Interface**: DisplayPort connection with USB touch input
- **Manufacturer**: HKC OVERSEAS LIMITED

## Key Features
- **Auto-detection**: Dynamically detects Hyte display by resolution characteristics
- **Isolated Session**: Dedicated `touchdisplay` user with separate Wayland session
- **Touch Interface**: Custom QuickShell-based touch widgets
- **System Monitoring**: Temperature graphs, usage stats, GPU monitoring
- **Music Visualizer**: Audio-reactive display elements
- **Background Management**: Dynamic background changing
- **Security**: Disabled keybindings, isolated from main desktop

## Architecture
- **Main Desktop**: Hyprland (excludes Hyte display)
- **Touch Display**: Sway + QuickShell widgets
- **User Separation**: `touchdisplay` system user for display session
- **Auto-start**: Systemd services for automatic session management

## Use Case
Perfect for PC enthusiasts with Hyte cases who want to utilize their touch display for:
- System monitoring (temps, usage, GPU stats)
- Music visualization
- Custom touch controls
- Aesthetic enhancement of their build
