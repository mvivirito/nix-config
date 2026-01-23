{ lib, pkgs, config, inputs, ... }:

{
  imports = [
    ./packages.nix
    ./keybinds.nix
    ./settings.nix
    ./monitors.nix
  ];

  # Enable Hyprland window manager
  # systemd.enable = false because UWSM handles systemd integration now
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };

  # Hyprpaper wallpaper service
  services.hyprpaper = {
    enable = false; # Disabled to show solid background color
    settings = {
      # Put your wallpaper at this path to take effect
      preload = [
        "$HOME/Pictures/wallpapers/modern.jpg"
      ];
      wallpaper = [
        "DP-2,$HOME/Pictures/wallpapers/modern.jpg"
        "eDP-1,$HOME/Pictures/wallpapers/modern.jpg"
      ];
      splash = false;
    };
  };
}
