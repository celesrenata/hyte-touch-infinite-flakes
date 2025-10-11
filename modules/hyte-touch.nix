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
    # Disable DP-3 at kernel level (ChatGPT's Option 1 - bulletproof)
    boot.kernelParams = [ "video=card1-DP-3:d" ];

    users.users.touchdisplay = {
      isSystemUser = true;
      group = "touchdisplay";
      home = "/var/lib/touchdisplay";
      createHome = true;
      shell = pkgs.shadow;
      extraGroups = [ "video" "input" ];
    };

    users.groups.touchdisplay = {};

    # Auto-login service for touch display user
    systemd.services.touchdisplay-session = {
      description = "Touch Display Wayland Session";
      after = [ "graphical-session.target" ];
      wantedBy = [ "multi-user.target" ];
      
      environment = {
        XDG_RUNTIME_DIR = "/run/user/999";
        WAYLAND_DISPLAY = "wayland-1";
        WLR_BACKENDS = "drm";
        WLR_DRM_DEVICES = "/dev/dri/card1";
      };
      
      serviceConfig = {
        Type = "simple";
        User = "touchdisplay";
        Group = "touchdisplay";
        PAMName = "login";
        TTYPath = "/dev/tty7";
        StandardInput = "tty";
        UnsetEnvironment = "TERM";
        
        # Security restrictions
        PrivateNetwork = false;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/touchdisplay" "/tmp" ];
        
        Restart = "always";
        RestartSec = "5s";
      };
      
      script = ''
        # Re-enable DP-3 that was disabled by kernel parameter
        echo on > /sys/class/drm/card1-DP-3/dpms 2>/dev/null || true
        
        export HYTE_DISPLAY=$(${hyteDetectScript})
        if [ -n "$HYTE_DISPLAY" ]; then
          export WLR_DRM_CONNECTORS="$HYTE_DISPLAY"
          
          # Start Hyprland for touch display
          exec ${pkgs.hyprland}/bin/Hyprland -c ${./hyte-hyprland.conf}
        else
          echo "Hyte display not detected, exiting..."
          exit 1
        fi
      '';
    };

    # Runtime directory for touchdisplay user
    systemd.tmpfiles.rules = [
      "d /run/user/999 0700 touchdisplay touchdisplay -"
    ];

    # Required packages
    environment.systemPackages = with pkgs; [
      hyprland
      quickshell
      gamescope
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
