{ config, lib, pkgs, ... }:

{
  # Steam, Proton, and gaming ecosystem
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;

    # Proton-GE for better game compatibility
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    # Remote play firewall rules
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Gamescope compositor for games
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # GameMode for performance optimization
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 1;  # NVIDIA GPU
      };
    };
  };

  # Xbox controller support (Bluetooth)
  hardware.xpadneo.enable = true;

  # 8BitDo controller udev rules (Steam needs hidraw access)
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="2dc8", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0660", TAG+="uaccess"
  '';

  # Steam hardware (controllers, VR)
  hardware.steam-hardware.enable = true;

  # 32-bit graphics support (many games need this)
  hardware.graphics.enable32Bit = true;

  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris
    heroic

    # Proton/Wine tools
    protontricks
    winetricks

    # Performance monitoring
    mangohud
    goverlay

    # Emulators
    retroarch
    dolphin-emu    # GameCube/Wii
    rpcs3          # PS3
    pcsx2          # PS2
    ppsspp         # PSP
    # duckstation  # PS1 - temporarily disabled (hash mismatch in nixpkgs)
    cemu           # Wii U

    # Vulkan
    vulkan-tools
    vulkan-loader

    # Additional gaming utilities
    gamemode
    wine-staging
    winetricks
  ];

  # Add user to gamemode group
  users.users.michael.extraGroups = [ "gamemode" ];
}
