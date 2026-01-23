
{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = ./rofi-theme.rasi;
    terminal = "${pkgs.kitty}/bin/kitty";
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {
      modi = "run,drun,calc:qalc";
      run-command = "${pkgs.kitty}/bin/kitty -e {cmd}";
    };
  };
}
