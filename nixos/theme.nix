{ pkgs, ... }:

{
  # Tokyo Night GTK theme (dark) — Qt follows it via the gtk2 platform theme
  environment.variables.GTK_THEME = "Tokyonight-Dark";
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Console colors (Tokyo Night palette)
  console = {
    earlySetup = true;
    colors = [
      # Normal colors
      "1a1b26"  # bg (background)
      "f7768e"  # red
      "9ece6a"  # green
      "e0af68"  # yellow
      "7aa2f7"  # blue
      "bb9af7"  # purple
      "7dcfff"  # cyan
      "a9b1d6"  # fg (text)

      # Bright colors
      "414868"  # bright black
      "f7768e"  # bright red
      "9ece6a"  # bright green
      "e0af68"  # bright yellow
      "7aa2f7"  # bright blue
      "bb9af7"  # bright purple
      "7dcfff"  # bright cyan
      "c0caf5"  # fg (bright white)
    ];
  };

  environment.systemPackages = with pkgs; [
    tokyonight-gtk-theme
  ];
}
