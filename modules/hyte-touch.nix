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
      docker
      docker-compose
    ];

    # Enable seatd for seat management
    services.seatd = {
      enable = true;
      user = "root";
      group = "seat";
    };

    # Add touchdisplay user to seat group
    users.groups.seat.members = [ "touchdisplay" ];

    # Add user to groups for DRM and seat access
    users.users.celes.extraGroups = [ "docker" "input" "video" "seat" ];
    
    # Enable seatd for multi-session DRM access
    services.seatd = {
      enable = true;
      user = "celes";
      group = "seat";
    };
    
    # Touch input support
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
