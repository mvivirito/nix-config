
{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = "glue_pro_blue";
    terminal = "${pkgs.kitty}/bin/kitty";
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {
	  modi = "calc:qalc";
	};
  };
}


