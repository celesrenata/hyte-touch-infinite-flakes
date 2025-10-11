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
in

{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display" // { default = true; };
  };

  config = mkIf config.services.hyte-touch.enable {
    # Don't disable DP-3 at kernel level - let gamescope access it
    # boot.kernelParams = [ "video=DP-3:d" ];

    # Configure GDM to ignore DP-3
    services.xserver.displayManager.gdm.settings = {
      greeter = {
        IncludeAll = false;
        Exclude = "DP-3";
      };
    };

    # Udev rule to block DP-3 access completely
    services.udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card1-DP-3", OWNER="root", GROUP="root", MODE="0000", RUN+="${pkgs.coreutils}/bin/touch /tmp/udev_dp3_blocked"
    '';

    # Create touchdisplay user
    users.users.touchdisplay = {
      isSystemUser = true;
      group = "touchdisplay";
      home = "/var/lib/touchdisplay";
      createHome = true;
      shell = pkgs.shadow;
      extraGroups = [ "video" "input" ];
    };
    users.groups.touchdisplay = {};

    # PAM configuration for touchdisplay user
    security.pam.services.touchdisplay = {
      allowNullPassword = true;
      startSession = true;
    };

    # Required packages
    environment.systemPackages = with pkgs; [
      gamescope
      alacritty
      quickshell
    ];

    # Auto-starting system service for DP-3 (runs as touchdisplay user)
    systemd.services.hyte-touch-display = {
      description = "Hyte Touch Display Service";
      after = [ "multi-user.target" "graphical-session.target" ];
      wantedBy = [ "graphical.target" ];
      
      environment = {
        XDG_RUNTIME_DIR = "/run/user/989";
        WLR_DRM_DEVICES = "/dev/dri/card1";
        WLR_DRM_CONNECTORS = "DP-3";
      };
      
      serviceConfig = {
        Type = "simple";
        User = "touchdisplay";
        Group = "touchdisplay";
        PAMName = "touchdisplay";
        Restart = "always";
        RestartSec = "5s";
      };
      
      script = ''
        # Try gamescope targeting DP-3 directly
        exec ${pkgs.gamescope}/bin/gamescope -O DP-3 -- ${pkgs.alacritty}/bin/alacritty
      '';
    };

    # Runtime directory for touchdisplay user  
    systemd.tmpfiles.rules = [
      "d /run/user/989 0700 touchdisplay touchdisplay -"
    ];

    # Enable required services
    services.udev.enable = true;
    hardware.opengl.enable = true;
    
    # Touch input support
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
