{ pkgs, ... }:

{

  programs.waybar = {
    enable = true;
    };

  xdg.configFile."waybar/config".source = ./config;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/macchiato.css".source = ./macchiato.css;
}


