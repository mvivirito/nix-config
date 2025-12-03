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

      # Catppuccin Macchiato color scheme (matches GTK/appearance setup)
      foreground = "#cad3f5";
      background = "#24273a";
      cursor = "#f5bde6";

      color0 = "#24273a";
      color8 = "#5b6078";
      color1 = "#ed8796";
      color9 = "#ed8796";
      color2 = "#a6da95";
      color10 = "#a6da95";
      color3 = "#eed49f";
      color11 = "#eed49f";
      color4 = "#8aadf4";
      color12 = "#8aadf4";
      color5 = "#f5bde6";
      color13 = "#f5bde6";
      color6 = "#8bd5ca";
      color14 = "#8bd5ca";
      color7 = "#a5adcb";
      color15 = "#cad3f5";

      selection_foreground = "#24273a";
      selection_background = "#8bd5ca";

      # Disable cursor blinking
      cursor_blink_interval = "0";

      # Big fat scrollback buffer
      scrollback_lines = "100000";
      # Set scrollback buffer for pager in MB
      scrollback_pager_history_size = "256";

      # Don't copy on select
      copy_on_select = "no";

      # Set program to open urls with
      open_url_with = "xdg-open";

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

