{ pkgs, quickshell }:

let
  touchConfigDir = pkgs.runCommand "touch-config" {} ''
    mkdir -p $out/quickshell/touch
    cp ${../config/quickshell/shell.qml} $out/quickshell/touch/shell.qml
    cp -r ${../config/quickshell/widgets} $out/quickshell/touch/ || true
  '';
in
pkgs.writeShellScriptBin "hyte-touch-interface" ''
  export XDG_CONFIG_HOME=${touchConfigDir}
  export QML_IMPORT_PATH="${quickshell}/lib/qt-6/qml"
  exec ${quickshell}/bin/quickshell -c touch
''
