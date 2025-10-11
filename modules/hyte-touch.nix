{ config, lib, pkgs, ... }:

with lib;

let
  hyteDetectScript = pkgs.writeShellScript "detect-hyte-display" ''
    for card in /sys/class/drm/card*-DP-*; do
      if [[ -f "$card/status" && "$(cat "$card/status")" == "connected" ]]; then
        if [[ -f "$card/modes" ]]; then
          if grep -q "2560x682\|3840x1100" "$card/modes"; then
            basename "$card" | sed 's/card[0-9]*-//'
            exit 0
          fi
        fi
      fi
    done
    exit 1
  '';

  # Detect GPU type
  hasNvidia = config.hardware.nvidia.modesetting.enable or false || 
              (builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers);
  hasAMD = builtins.any (driver: builtins.elem driver ["amdgpu" "radeon"]) config.services.xserver.videoDrivers;
in

{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display" // { default = true; };
  };

  config = mkIf config.services.hyte-touch.enable {
    # Configure Hyprland via Home Manager to ignore DP-3
    home-manager.users.celes = {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          monitor = [ "DP-3,disable" ];
        };
      };
    };

    # Don't disable DP-3 at kernel level - let gamescope access it
    # boot.kernelParams = [ "video=DP-3:d" ];

    # Configure GDM to ignore DP-3
    services.xserver.displayManager.gdm.settings = {
      greeter = {
        IncludeAll = false;
        Exclude = "DP-3";
      };
    };

    # Udev rule to grant touchdisplay user access to card1
    services.udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card1", RUN+="${pkgs.acl}/bin/setfacl -m u:touchdisplay:rw /dev/dri/card1"
    '';

    # Create touchdisplay user with GPU access
    users.users.touchdisplay = {
      isSystemUser = true;
      group = "touchdisplay";
      home = "/var/lib/touchdisplay";
      createHome = true;
      shell = pkgs.shadow;
      extraGroups = [ "video" "input" "render" ];
    };
    users.groups.touchdisplay = {};

    # PAM configuration for touchdisplay user
    security.pam.services.touchdisplay = {
      allowNullPassword = true;
      startSession = true;
    };

    # Required packages
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];

    # Enable Docker
    virtualisation.docker.enable = true;
    virtualisation.docker.enableNvidia = true;

    # Docker container service for Hyte touch display
    systemd.services.hyte-touch-display = {
      description = "Hyte Touch Display Docker Container";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.docker}/bin/docker run -d --name hyte-touch --restart unless-stopped --gpus all --device /dev/dri/card1:/dev/dri/card1 --device /dev/dri/renderD128:/dev/dri/renderD128 --privileged -v ${./weston.ini}:/etc/weston/weston.ini:ro hyte-weston";
        ExecStop = "${pkgs.docker}/bin/docker stop hyte-touch";
        ExecStopPost = "${pkgs.docker}/bin/docker rm hyte-touch";
      };
    };

    # Runtime directory for touchdisplay user  
    systemd.tmpfiles.rules = [
      "d /run/user/989 0700 touchdisplay touchdisplay -"
    ];
    
    # Touch input support
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
