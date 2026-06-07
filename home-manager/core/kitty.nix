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

      # Tokyo Night (Night) color scheme
      foreground = "#c0caf5";
      background = "#1a1b26";
      cursor = "#c0caf5";

      color0 = "#15161e";
      color8 = "#414868";
      color1 = "#f7768e";
      color9 = "#f7768e";
      color2 = "#9ece6a";
      color10 = "#9ece6a";
      color3 = "#e0af68";
      color11 = "#e0af68";
      color4 = "#7aa2f7";
      color12 = "#7aa2f7";
      color5 = "#bb9af7";
      color13 = "#bb9af7";
      color6 = "#7dcfff";
      color14 = "#7dcfff";
      color7 = "#a9b1d6";
      color15 = "#c0caf5";

      selection_foreground = "#1a1b26";
      selection_background = "#283457";

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
