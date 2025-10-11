# Overlay to filter DP-3 from quickshell modules
# This prevents the main desktop quickshell from showing on the touch display

final: prev: {
  quickshell-dp3-filter = {
    # Function to apply DP-3 filter to quickshell config files
    applyFilter = configPath: 
      prev.runCommand "quickshell-dp3-filtered" {} ''
        mkdir -p $out
        cp -r ${configPath}/* $out/
        
        # Filter DP-3 from all quickshell modules that use Quickshell.screens
        for file in $out/modules/*/*.qml; do
          if [ -f "$file" ]; then
            sed -i 's/model: Quickshell\.screens/model: Quickshell.screens.filter(screen => screen.name !== "DP-3")/g' "$file"
          fi
        done
      '';
  };
}
