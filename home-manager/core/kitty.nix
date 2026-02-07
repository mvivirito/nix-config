{
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    settings = {
      #bold_font = "Mplus Code 60";
      # Add nerd font symbol map. Not sure why it is suddenly needed since 0.32.0 (https://github.com/kovidgoyal/kitty/issues/7081)
      #symbol_map = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A2,U+E0A3,U+E0B0-U+E0B3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B1,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F372,U+F400-U+F532,U+F500-U+FD46,U+F0001-U+F1AF0 Symbols Nerd Font Mono";

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
