{ pkgs, quickshell }:

let
  configDir = pkgs.runCommand "touch-config" {} ''
    mkdir -p $out
    cp ${../config/quickshell/shell.qml} $out/shell.qml
    cp ${../config/quickshell/qmldir} $out/qmldir
    cp ${../config/quickshell/SystemMonitor.qml} $out/SystemMonitor.qml
    cp -r ${../config/quickshell/widgets} $out/widgets
  '';
in
pkgs.symlinkJoin {
  name = "hyte-touch-interface";
  paths = [ quickshell ];
  buildInputs = with pkgs; [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/qs \
      --set QML2_IMPORT_PATH "${quickshell}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtpositioning}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qtcharts}/lib/qt-6/qml:${configDir}" \
      --add-flags "--path ${configDir}/shell.qml"
    
    ln -sf $out/bin/qs $out/bin/hyte-touch-interface
  '';
}
