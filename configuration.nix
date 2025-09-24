{ config, pkgs, ... }:

{
  # Minimal boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Minimal filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Enable the Hyte touch display service (auto-detects display)
  services.hyte-touch.enable = true;
  
  # Enable Wayland and required services
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
  };
  
  # Enable Hyprland for main user
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # Required packages for touch display functionality
  environment.systemPackages = with pkgs; [
    sway
    lm_sensors
    procps
    pciutils
    usbutils
  ];
  
  # Enable hardware sensors
  hardware.sensor.iio.enable = true;
  
  # Graphics drivers
  hardware.graphics.enable = true;
  
  # Audio support for music visualizer
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  # Touch input support
  services.xserver.libinput = {
    enable = true;
    touchpad.tapping = true;
  };
  
  # User configuration
  users.users.celes = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ];
  };
  
  system.stateVersion = "24.05";
}
