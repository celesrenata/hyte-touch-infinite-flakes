{ config, lib, pkgs, ... }:

with lib;

{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display";
    
    displayOutput = mkOption {
      type = types.str;
      default = "DP-3";
      description = "Display output for the touch screen";
    };
    
    touchDevice = mkOption {
      type = types.str;
      default = "/dev/input/by-id/usb-*touch*";
      description = "Touch input device path";
    };
  };

  config = mkIf config.services.hyte-touch.enable {
    # Create locked-down user for touch display
    users.users.touchdisplay = {
      isSystemUser = true;
      group = "touchdisplay";
      shell = pkgs.shadow;
      home = "/var/lib/touchdisplay";
      createHome = true;
    };
    
    users.groups.touchdisplay = {};

    # Prevent Hyprland from grabbing the touch display
    environment.etc."hypr/hyprland-exclude.conf".text = ''
      monitor=${config.services.hyte-touch.displayOutput},disable
    '';

    # Auto-login service for touch display user
    systemd.services.touchdisplay-session = {
      description = "Touch Display Wayland Session";
      after = [ "graphical-session.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = "touchdisplay";
        Group = "touchdisplay";
        WorkingDirectory = "/var/lib/touchdisplay";
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/999"
          "WAYLAND_DISPLAY=wayland-1"
          "DISPLAY=:1"
        ];
        ExecStart = "${pkgs.sway}/bin/sway --config /etc/sway/touchdisplay.conf";
        Restart = "always";
        RestartSec = "3";
      };
    };

    # Touch display Sway configuration
    environment.etc."sway/touchdisplay.conf".text = ''
      output ${config.services.hyte-touch.displayOutput} enable
      
      input type:touch {
        map_to_output ${config.services.hyte-touch.displayOutput}
      }
      
      exec quickshell -c /etc/quickshell/touch-config.qml
      
      # Disable all keybindings for security
      unbindall
    '';

    # System runtime directory for touchdisplay user
    systemd.tmpfiles.rules = [
      "d /run/user/999 0755 touchdisplay touchdisplay -"
    ];
  };
}
