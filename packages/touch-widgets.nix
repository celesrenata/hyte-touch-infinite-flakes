{ lib, stdenv, quickshell }:

stdenv.mkDerivation rec {
  pname = "hyte-touch-widgets";
  version = "1.0.0";
  
  src = ../config/quickshell;
  
  buildInputs = [ quickshell.packages.${stdenv.system}.default ];
  
  installPhase = ''
    mkdir -p $out/share/quickshell
    cp -r * $out/share/quickshell/
    
    # Create wrapper script
    mkdir -p $out/bin
    cat > $out/bin/hyte-touch-interface << 'EOF'
#!/bin/sh
exec ${quickshell.packages.${stdenv.system}.default}/bin/quickshell -c $out/share/quickshell/touch-config.qml "$@"
EOF
    chmod +x $out/bin/hyte-touch-interface
  '';
  
  meta = with lib; {
    description = "Touch interface widgets for Hyte Y70 display";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
