{ pkgs, ... }:

{
  gtk = {
    enable = true;
    font = {
      package = pkgs.nerd-fonts.mononoki;
      name = "Mononoki Nerd Font Regular";
      size = 12;
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
