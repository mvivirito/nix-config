{ pkgs, ... }:

{
  # Catppuccin Mocha theme - darker, higher contrast than Macchiato
  environment.variables.GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Console colors (Gruvbox Dark palette)
  console = {
    earlySetup = true;
    colors = [
      # Normal colors
      "282828"  # bg (background)
      "cc241d"  # red
      "98971a"  # green
      "d79921"  # yellow
      "458588"  # blue
      "b16286"  # purple
      "689d6a"  # aqua
      "a89984"  # fg4 (text)

      # Bright colors
      "928374"  # gray (bright black)
      "fb4934"  # bright red
      "b8bb26"  # bright green
      "fabd2f"  # bright yellow
      "83a598"  # bright blue
      "d3869b"  # bright purple
      "8ec07c"  # bright aqua
      "ebdbb2"  # fg (bright white)
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
