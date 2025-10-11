{ pkgs, quickshell }:

let
  touchConfig = ../config/quickshell/touch-config.qml;
in
pkgs.writeShellScriptBin "hyte-touch-interface" ''
  export QML_IMPORT_PATH="${quickshell}/lib/qt-6/qml"
  exec ${quickshell}/bin/quickshell -c ${touchConfig}
''
