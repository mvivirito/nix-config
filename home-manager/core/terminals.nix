{ pkgs, lib, ... }:

{
  # Ghostty - fast GPU-accelerated terminal emulator
  #
  # Features:
  # - 4x faster plain text rendering
  # - Native platform UI (GTK on Linux, Metal on macOS)
  # - Kitty graphics protocol support (images in terminal)
  # - Kitty keyboard protocol (better key handling for neovim)
  # - Zero-config sensible defaults
  #
  # On macOS: package = null (Homebrew handles installation)
  # On Linux: package from nixpkgs

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    # Skip package installation on macOS (use Homebrew cask instead)
    package = lib.mkIf pkgs.stdenv.isDarwin null;

    settings = {
      # Transparency (matches old kitty config)
      background-opacity = 0.8;

      # Cursor
      cursor-style = "block";
      cursor-style-blink = false;

      # Scrollback
      scrollback-limit = 100000;

      # Clipboard
      copy-on-select = "clipboard";

      # Window - let compositor handle decorations
      window-decoration = true;

      # Font (optional - ghostty has good defaults)
      # font-family = "JetBrainsMono Nerd Font";
      # font-size = 12;
    };
  };
}
