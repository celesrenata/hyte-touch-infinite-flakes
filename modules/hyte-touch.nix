{ config, lib, pkgs, ... }:

with lib;

{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display" // { default = true; };
  };

  config = mkIf config.services.hyte-touch.enable {
    # Configure GDM to ignore DP-3
    services.xserver.displayManager.gdm.settings = {
      greeter = {
        IncludeAll = false;
        Exclude = "DP-3";
      };
    };

    # Required packages
    environment.systemPackages = with pkgs; [
      weston
      alacritty
      quickshell
    ];

    # Enable seatd for seat management
    services.seatd = {
      enable = true;
      user = "celes";
      group = "seat";
    };

    # Add touchdisplay user to seat group
    users.groups.seat.members = [ "touchdisplay" ];

    # Add user to groups for DRM and seat access
    users.users.celes.extraGroups = [ "docker" "input" "video" "seat" ];
    
    # Touch input support
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    # User service to start weston on DP-3 with seatd
    systemd.user.services.hyte-touch-display = {
      description = "Hyte Touch Display Service";
      after = [ "seatd.service" ];
      wantedBy = [ "default.target" ];
      
      environment = {
        XDG_RUNTIME_DIR = "/run/user/%i";
        LIBSEAT_BACKEND = "seatd";
      };
      
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
      };
      
      script = ''
        exec ${pkgs.weston}/bin/weston --backend=drm --drm-device=/dev/dri/card1 --output-name=DP-3
      '';
    };
  };
}
