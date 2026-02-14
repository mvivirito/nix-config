{ pkgs, ... }:

{
  # Enable X11 (required for KDE even with Wayland)
  services.xserver.enable = true;

  # KDE Plasma 6 desktop environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE default packages
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.konsole
    kdePackages.dolphin
  ];
}
