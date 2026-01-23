{ pkgs, ... }:

{
  # Catppuccin Mocha theme - darker, higher contrast than Macchiato
  environment.variables.GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Console colors (Catppuccin Mocha palette)
  console = {
    earlySetup = true;
    colors = [
      # Normal colors
      "1e1e2e"  # base (background)
      "f38ba8"  # red
      "a6e3a1"  # green
      "f9e2af"  # yellow
      "89b4fa"  # blue
      "f5c2e7"  # pink
      "94e2d5"  # teal
      "cdd6f4"  # text

      # Bright colors
      "585b70"  # surface1 (bright black)
      "f38ba8"  # bright red
      "a6e3a1"  # bright green
      "f9e2af"  # bright yellow
      "89b4fa"  # bright blue
      "f5c2e7"  # bright pink
      "94e2d5"  # bright teal
      "bac2de"  # subtext0 (bright white)
    ];
  };

  # Override packages for Mocha variant with Blue accent
  nixpkgs.config.packageOverrides = pkgs: {
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "blue" ];
      size = "standard";
      variant = "mocha";
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-gtk
    catppuccin-kvantum
  ];
}
