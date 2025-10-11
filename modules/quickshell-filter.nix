{ config, lib, pkgs, ... }:

{
  # Apply DP-3 filter to user's quickshell configuration
  systemd.user.services.quickshell-dp3-filter = {
    description = "Apply DP-3 filter to quickshell config";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Backup original configs if not already done
      if [ ! -d ~/.config/quickshell/ii.backup ]; then
        cp -r ~/.config/quickshell/ii ~/.config/quickshell/ii.backup
      fi
      
      # Apply DP-3 filter to quickshell modules
      for file in ~/.config/quickshell/ii/modules/*/*.qml; do
        if [ -f "$file" ] && ! grep -q 'screen.name !== "DP-3"' "$file"; then
          sed -i 's/model: Quickshell\.screens/model: Quickshell.screens.filter(screen => screen.name !== "DP-3")/g' "$file"
        fi
      done
    '';
  };
}
