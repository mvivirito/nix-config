{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  # System-level Niri configuration
  # User-level config (keybinds, settings) is in home-manager/linux/niri/

  # Enable Niri compositor system-wide via niri-flake
  programs.niri = {
    enable = true;
  };

  # XWayland for legacy X11 applications
  # Niri handles this per-window when needed

  # System-level security and authentication
  security = {
    polkit.enable = true;
    # PAM service for DMS lock screen
    pam.services.dms = {};
  };

  # System services required for desktop functionality
  # (carried over from hyprland.nix)
  services = {
    gvfs.enable = true;           # Virtual filesystem (USB, network shares, MTP)
    devmon.enable = true;         # Device mounting daemon
    udisks2.enable = true;        # Disk management (automount)
    upower.enable = true;         # Power management (battery status)
    power-profiles-daemon.enable = true;  # Power profiles
    accounts-daemon.enable = true;        # User account information
    thermald.enable = true;               # Intel thermal management daemon
  };

  # DMS (Dank Material Shell) is spawned by niri via enableSpawn in home-manager/linux/dms.nix
  # Do NOT enable dms-shell at system level - it conflicts with niri spawn (starts before display available)
  # programs.dms-shell.enable = false;  # Not needed - defaults to false
}
