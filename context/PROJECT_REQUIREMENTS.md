# Hyte Y70 Touch-Infinite Display Project Requirements

## Original User Request

Hello! Today we are working on a new project! Yaay! I am so excited! I got my Hyte Y70 Case and it comes with this thing called the touch-infinite display. It uses a displayport loopback in the case to power a small screen that I just plugged in. I would like to write the context files to create the nix flakes to do the following:

1. **Prevent Hyprland from grabbing the display in multimon**
2. **Create a new locked down user account with no shell access**
3. **Have Wayland start with that user automatically in that little display**
4. **Custom Hyprland + Quickshell setup with widgets:**
   - Temperatures of core components (CPU, RAM, GPU, Ambient) in horizontal line graph with legend
   - Usage of CPU, RAM, GPU, Mounted Partitions
   - Background changer widget (static/animated/videos)
   - Music visualizer for logged in user (not the shellless account)
5. **Ensure touchpad on display is captured by Wayland session**
6. **Swiping and tapping support for quickshell navigation**
7. **Customizable dimming settings for the screen**
8. **Save original prompt for context window overflow reference**

## Technical Architecture

- Main user runs Hyprland on primary displays
- Dedicated user account for touch display (no shell access)
- Wayland compositor on touch display
- Quickshell for widget interface
- Touch input handling
- System monitoring integration
- Media visualization
