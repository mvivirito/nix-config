
{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = ./rofi-theme.rasi;
    terminal = "${pkgs.kitty}/bin/kitty";
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {
	  modi = "calc:qalc";
	};
  };
}

