{ pkgs, ... }:

{
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaBlue;
    name = "Catppuccin-Mocha-Blue-Cursors";
    size = 40;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      package = (pkgs.nerdfonts.override { fonts = [ "Mononoki" ]; });
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
