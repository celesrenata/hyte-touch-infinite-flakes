{ config, lib, pkgs, quickshell, ... }:

with lib;

let
  hyteDetectScript = pkgs.writeShellScript "detect-hyte-display" ''
    # Dynamic Hyte touch display detection
    detect_hyte_display() {
        for card in /sys/class/drm/card*-DP-*; do
            if [[ -f "$card/status" && "$(cat "$card/status")" == "connected" ]]; then
                if [[ -f "$card/modes" ]]; then
                    if grep -q "2560x682\|3840x1100" "$card/modes"; then
                        basename "$card" | sed 's/card[0-9]*-//'
                        return 0
                    fi
                fi
            fi
        done
        return 1
    }
    
    detect_hyte_display
  '';
in
{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display";
  };

  config = mkIf config.services.hyte-touch.enable {
    users.users.touchdisplay = {
      isSystemUser = true;
      group = "touchdisplay";
      shell = pkgs.shadow;
      home = "/var/lib/touchdisplay";
      createHome = true;
    };
    
    users.groups.touchdisplay = {};

    # Dynamic Hyprland exclusion service
    systemd.services.hyprland-exclude-hyte = {
      description = "Exclude Hyte display from Hyprland";
      before = [ "display-manager.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        HYTE_DISPLAY=$(${hyteDetectScript})
        if [ -n "$HYTE_DISPLAY" ]; then
          mkdir -p /etc/hypr
          echo "monitor=$HYTE_DISPLAY,disable" > /etc/hypr/hyprland-exclude.conf
          echo "Excluded $HYTE_DISPLAY from Hyprland"
        fi
      '';
    };

    # Auto-login service for touch display user
    systemd.services.touchdisplay-session = {
      description = "Touch Display Wayland Session";
      after = [ "hyprland-exclude-hyte.service" "graphical-session.target" ];
      wants = [ "hyprland-exclude-hyte.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = "touchdisplay";
        Group = "touchdisplay";
        WorkingDirectory = "/var/lib/touchdisplay";
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/999"
          "WAYLAND_DISPLAY=wayland-1"
        ];
        Restart = "always";
        RestartSec = "3";
      };
      
      script = ''
        HYTE_DISPLAY=$(${hyteDetectScript})
        if [ -n "$HYTE_DISPLAY" ]; then
          export HYTE_DISPLAY
          exec ${pkgs.sway}/bin/sway --config /etc/sway/touchdisplay.conf
        else
          echo "Hyte display not detected, exiting"
          exit 1
        fi
      '';
    };

    # Dynamic Sway configuration
    environment.etc."sway/touchdisplay.conf".text = ''
      exec_always {
        HYTE_DISPLAY=$(${hyteDetectScript})
        if [ -n "$HYTE_DISPLAY" ]; then
          swaymsg output $HYTE_DISPLAY enable
          # Map touch input to the Hyte display
          for touch_device in $(swaymsg -t get_inputs | jq -r '.[] | select(.type=="touch") | .identifier'); do
            swaymsg input $touch_device map_to_output $HYTE_DISPLAY
          done
        fi
      }
      
      exec ${pkgs.callPackage ../packages/touch-widgets.nix { inherit quickshell; }}/bin/hyte-touch-interface
      
      # Disable all keybindings for security
      unbindall
    '';

    # System runtime directory for touchdisplay user
    systemd.tmpfiles.rules = [
      "d /run/user/999 0755 touchdisplay touchdisplay -"
      "d /var/lib/touchdisplay/backgrounds 0755 touchdisplay touchdisplay -"
    ];

    # Add touch-widgets package to system packages
    environment.systemPackages = with pkgs; [
      (callPackage ../packages/touch-widgets.nix { inherit quickshell; })
      jq  # For touch input detection
    ];
  };
}
