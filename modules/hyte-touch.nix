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
      weston
      alacritty
      quickshell
    ];

    # Auto-starting system service for DP-3 (runs as touchdisplay user)
    systemd.services.hyte-touch-display = {
      description = "Hyte Touch Display Service";
      before = [ "display-manager.service" "gdm.service" "graphical.target" ];
      after = [ "systemd-logind.service" "dbus.service" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "systemd-logind.service" ];
      
      environment = {
        XDG_RUNTIME_DIR = "/run/user/989";
        WLR_DRM_DEVICES = "/dev/dri/card1";
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
        # Start weston with DRM backend on VT7 targeting DP-3
        exec ${pkgs.weston}/bin/weston --backend=drm --drm-device=/dev/dri/card1 --tty=7 --output-name=DP-3
      '';
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
