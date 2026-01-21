{ pkgs, ... }:

{
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };
    iconTheme = {
      package = (pkgs.catppuccin-papirus-folders.override { flavor = "mocha"; });
      name  = "Papirus-Dark";
    };
    theme = {
      package = (pkgs.catppuccin-gtk.override { accents = ["blue"] ; size = "standard"; variant = "mocha"; });
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
    };
  };
}
