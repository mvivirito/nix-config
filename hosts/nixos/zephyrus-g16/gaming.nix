{ config, lib, pkgs, ... }:

{
  # Steam, Proton, and gaming ecosystem
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;

    # Proton-GE for better game compatibility
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    # Remote play firewall rules
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
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
    wineWow64Packages.stableFull
    winetricks

    # Wine prefix manager (nicer UX than raw winetricks)
    bottles

    # Run Proton outside Steam (used by Lutris/Heroic)
    umu-launcher

    # NVENC ShadowPlay-style replay buffer / recording
    gpu-screen-recorder
    gpu-screen-recorder-gtk

    # Logitech wireless device manager
    solaar

    # Cross-vendor RGB control (complements asusctl for peripherals)
    openrgb-with-all-plugins
  ];

  # Add user to gamemode group
  users.users.michael.extraGroups = [ "gamemode" ];

  # Allow gamemode group to renice and lock memory for game processes.
  # Why: gamemode's renice = 10 silently no-ops without RLIMIT_NICE headroom;
  # memlock + rtprio help anti-cheat shims and audio threads avoid stalls.
  security.pam.loginLimits = [
    { domain = "@gamemode"; type = "-"; item = "nice";    value = "-10"; }
    { domain = "@gamemode"; type = "-"; item = "rtprio";  value = "20"; }
    { domain = "@gamemode"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  # Steam Deck-equivalent map count. Required by some modern games and EAC titles.
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  # ZRAM swap to absorb memory pressure during long sessions / shader compile.
  zramSwap.enable = true;
}
