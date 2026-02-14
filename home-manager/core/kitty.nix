{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    settings = {
      # Font configuration - use Nerd Font for icons (eza, starship, etc.)
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;

      # Do not wait for inherited child processes.
      close_on_child_death = "yes";
      # Only disable ligatures when the cursor is on them.
      disable_ligatures = "cursor";

      # Gruvbox Dark color scheme - high contrast, readable
      foreground = "#ebdbb2";
      background = "#282828";
      cursor = "#ebdbb2";

      color0 = "#282828";
      color8 = "#928374";
      color1 = "#cc241d";
      color9 = "#fb4934";
      color2 = "#98971a";
      color10 = "#b8bb26";
      color3 = "#d79921";
      color11 = "#fabd2f";
      color4 = "#458588";
      color12 = "#83a598";
      color5 = "#b16286";
      color13 = "#d3869b";
      color6 = "#689d6a";
      color14 = "#8ec07c";
      color7 = "#a89984";
      color15 = "#ebdbb2";

      selection_foreground = "#282828";
      selection_background = "#83a598";

      # Disable cursor blinking
      cursor_blink_interval = "0";

      # Big fat scrollback buffer
      scrollback_lines = "100000";
      # Set scrollback buffer for pager in MB
      scrollback_pager_history_size = "256";

      # Make selection copy to clipboard/primary for easy cross-terminal paste
      copy_on_select = "yes";
      clipboard_control = "write-clipboard write-primary";

      # Set program to open urls with (platform-aware)
      open_url_with = if pkgs.stdenv.isDarwin then "open" else "xdg-open";

      # Fuck the bell
      enable_audio_bell = "no";
    };
    keybindings = {
      # Keyboard mappings
    };
    # XXX: mkForce to prevent stylix from appending theme.
    # Fix this by making a correct theme that can be used.
    # TODO aaaaaaaaaa
    extraConfig = lib.mkForce ''
      background_opacity 0.6
    '';
  };
}
