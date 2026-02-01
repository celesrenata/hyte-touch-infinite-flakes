{ config, lib, pkgs, quickshell, ... }:

with lib;

let
  startHyteTouch = pkgs.callPackage ../packages/start-hyte-touch.nix { inherit quickshell; };
in
{
  options.services.hyte-touch = {
    enable = mkEnableOption "Hyte Y70 Touch-Infinite Display" // { default = true; };
  };

  config = mkIf config.services.hyte-touch.enable {
    environment.systemPackages = with pkgs; [
      cage
      quickshell
      startHyteTouch
    ];

    systemd.user.services.hyte-touch-display = {
      description = "Hyte Touch Display Nested Session";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      
      environment = {
        XDG_RUNTIME_DIR = "/run/user/%i";
      };
      
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3s";
      };
      
      script = ''
        sleep 5
        exec ${startHyteTouch}/bin/start-hyte-touch
      '';
    };
  };
}
