{ pkgs, quickshell }:

let
  hyprlandConfig = ../config/hyprland-nested.conf;
in
pkgs.writeShellScriptBin "start-hyte-touch" ''
  export WAYLAND_DISPLAY=wayland-0
  export LD_LIBRARY_PATH=/run/current-system/sw/lib:$LD_LIBRARY_PATH
  
  exec /run/current-system/sw/bin/Hyprland -c ${hyprlandConfig}
''
