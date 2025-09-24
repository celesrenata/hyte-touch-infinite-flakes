{ lib, stdenv, makeWrapper, bash, lm_sensors, procps, nvidia-system-monitor-qt }:

stdenv.mkDerivation rec {
  pname = "hyte-system-monitor";
  version = "1.0.0";
  
  src = ../scripts;
  
  nativeBuildInputs = [ makeWrapper ];
  
  buildInputs = [ bash lm_sensors procps nvidia-system-monitor-qt ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp monitor-temps.sh $out/bin/
    cp monitor-usage.sh $out/bin/
    
    wrapProgram $out/bin/monitor-temps.sh \
      --prefix PATH : ${lib.makeBinPath [ lm_sensors ]}
      
    wrapProgram $out/bin/monitor-usage.sh \
      --prefix PATH : ${lib.makeBinPath [ procps nvidia-system-monitor-qt ]}
  '';
  
  meta = with lib; {
    description = "System monitoring scripts for Hyte touch display";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
