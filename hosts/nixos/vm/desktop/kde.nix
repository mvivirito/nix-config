{ pkgs, ... }:

{
  # Enable X11 (required for KDE even with Wayland)
  services.xserver.enable = true;

  # KDE Plasma 6 desktop environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE packages
  environment.systemPackages = with pkgs; [
    # Core KDE apps
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin

    # Additional KDE utilities
    kdePackages.okular              # PDF/document viewer
    kdePackages.gwenview            # Image viewer
    kdePackages.ark                 # Archive manager
    kdePackages.kcalc               # Calculator
    kdePackages.spectacle           # Screenshot tool
    kdePackages.kdeconnect-kde      # Phone integration
    kdePackages.filelight           # Disk usage visualizer
    kdePackages.plasma-browser-integration
    kdePackages.plasma-systemmonitor
    kdePackages.kdeplasma-addons

    # Catppuccin theming (apply via KDE System Settings)
    catppuccin-kde                  # KDE color schemes, window decorations
    catppuccin-kvantum              # Qt/Kvantum theme
    catppuccin-gtk                  # GTK apps within KDE
    (catppuccin-papirus-folders.override { flavor = "mocha"; })  # Icons
  ];

  # KDE Connect firewall rules
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
    allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
  };
}
