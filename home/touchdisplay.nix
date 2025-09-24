{ config, pkgs, quickshell, ... }:

{
  home.username = "touchdisplay";
  home.homeDirectory = "/var/lib/touchdisplay";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    quickshell.packages.${pkgs.system}.default
    libsensors
    lm_sensors
    nvidia-system-monitor-qt
    pulseaudio
  ];

  xdg.configFile."quickshell/touch-config.qml".source = ../config/quickshell/touch-config.qml;
  xdg.configFile."quickshell/widgets".source = ../config/quickshell/widgets;
  
  # Create backgrounds directory
  home.file."backgrounds/.keep".text = "";
  
  home.file.".config/touch-display/settings.json".text = builtins.toJSON {
    dimming = {
      enabled = true;
      timeout = 30;
      brightness_levels = [ 100 75 50 25 10 ];
    };
    widgets = {
      temperature_graph = true;
      system_usage = true;
      background_changer = true;
      music_visualizer = true;
    };
    touch = {
      swipe_sensitivity = 0.7;
      tap_timeout = 200;
    };
  };
}
