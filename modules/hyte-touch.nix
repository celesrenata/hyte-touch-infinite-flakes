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
    # Disable DP-3 at kernel level (working solution)
    boot.kernelParams = [ "video=DP-3:d" ];

    # Required packages
    environment.systemPackages = with pkgs; [
      gamescope
      chromium
      quickshell
    ];

    # Gamescope kiosk service for DP-3 (runs as main user)
    systemd.user.services."dp3-kiosk" = {
      description = "DP-3 dashboard (gamescope fullscreen)";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.gamescope}/bin/gamescope -f -O DP-3 -- \
            ${pkgs.chromium}/bin/chromium \
              --kiosk --noerrdialogs --disable-translate --overscroll-history-navigation=0 \
              --incognito --start-fullscreen --app=http://localhost:3000/dashboard
        '';
        Restart = "always";
      };
    };

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
