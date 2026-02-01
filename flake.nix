{
  description = "Hyte Y70 Touch-Infinite Display Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    quickshell.url = "github:outfoxxed/quickshell";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system; 
        overlays = [ self.overlays.default ];
      };
    in
    {
      # Overlay to fix quickshell Qt dependencies
      overlays.default = final: prev: {
        # Use nixpkgs quickshell which has consistent Qt versions
        quickshell = prev.quickshell or (quickshell.packages.${system}.default);
      };

      # Overlay to filter DP-3 from quickshell
      overlays.quickshell-dp3-filter = import ./overlays/quickshell-dp3-filter.nix;
      
      nixosModules.hyte-touch = import ./modules/hyte-touch.nix;
      
      nixosConfigurations.hyte-system = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit quickshell; };
        modules = [
          ./configuration.nix
          self.nixosModules.hyte-touch
          hyprland.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.touchdisplay = import ./home/touchdisplay.nix;
            home-manager.extraSpecialArgs = { inherit quickshell; };
          }
        ];
      };

      packages.${system} = {
        touch-widgets = pkgs.callPackage ./packages/touch-widgets.nix { inherit quickshell; };
        system-monitor = pkgs.callPackage ./packages/system-monitor.nix {};
        cursor-barrier = pkgs.writeShellScriptBin "cursor-barrier" (builtins.readFile ./scripts/cursor-barrier.sh);
        hyte-touch-interface = pkgs.callPackage ./packages/hyte-touch-interface.nix { quickshell = pkgs.quickshell; };
        start-hyte-touch = pkgs.callPackage ./packages/start-hyte-touch.nix { quickshell = pkgs.quickshell; };
      };
    };
}
