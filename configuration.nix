{ config, pkgs, ... }:

{
  # Enable the Hyte touch display service
  services.hyte-touch = {
    enable = true;
    displayOutput = "DP-3"; # Adjust based on your actual display output
    touchDevice = "/dev/input/by-id/usb-*touch*";
  };
  
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
  
  # Graphics drivers (adjust based on your GPU)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # NVIDIA support (if applicable)
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };
  
  # Audio support for music visualizer
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  
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
