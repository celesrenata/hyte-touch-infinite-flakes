{ pkgs, quickshell }:

let
  quickshellConfig = ../config/quickshell;
  nestedHyprlandConfig = pkgs.writeText "hyprland-nested.conf" ''
    monitor=,preferred,auto,1
    
    exec-once=${quickshell}/bin/quickshell -c ${quickshellConfig}
    
    misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
    }
    
    general {
        border_size = 0
        gaps_in = 0
        gaps_out = 0
    }
  '';
in
pkgs.writeShellScriptBin "start-hyte-touch" ''
  exec ${pkgs.hyprland}/bin/Hyprland -c ${nestedHyprlandConfig}
''
