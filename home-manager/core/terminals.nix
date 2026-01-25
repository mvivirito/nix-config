{ pkgs, lib, ... }:

{
  # Ghostty - fast GPU-accelerated terminal emulator
  # Replaces kitty as default terminal
  #
  # Features over kitty:
  # - 4x faster plain text rendering
  # - Native platform UI (GTK on Linux, Metal on macOS)
  # - Kitty graphics protocol support (images in terminal)
  # - Kitty keyboard protocol (better key handling for neovim)
  # - Zero-config sensible defaults

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Theme - let DMS matugen handle dynamic theming
      # Can set a fallback theme here if needed
      # theme = "catppuccin-mocha";

      # Transparency (matches old kitty config)
      background-opacity = 0.6;

      # Cursor
      cursor-style = "block";
      cursor-style-blink = false;

      # Scrollback
      scrollback-limit = 100000;

      # Clipboard
      copy-on-select = "clipboard";

      # Window - let compositor handle decorations
      window-decoration = false;

      # Font (optional - ghostty has good defaults)
      # font-family = "JetBrainsMono Nerd Font";
      # font-size = 12;
    };
  };
}
