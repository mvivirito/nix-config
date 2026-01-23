{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
    # System-level Hyprland configuration
    # User-level config (keybinds, settings, packages) is in home-manager/hyprland.nix

    services.xserver.displayManager.startx.enable = true;

    # Enable Hyprland compositor system-wide
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # System-level security and authentication
    security = {
      polkit.enable = true;
      pam.services.ags = {};
    };

    # System services required for desktop functionality
    services = {
      gvfs.enable = true;           # Virtual filesystem (USB, network shares, MTP)
      devmon.enable = true;          # Device mounting daemon
      udisks2.enable = true;         # Disk management (automount)
      upower.enable = true;          # Power management (battery status)
      power-profiles-daemon.enable = true;  # Power profiles
      accounts-daemon.enable = true;  # User account information
    };
}

