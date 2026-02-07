{ pkgs, lib, ... }:

{
  # Alacritty - fast GPU-accelerated terminal emulator
  #
  # Features:
  # - GPU-accelerated rendering for high performance
  # - Cross-platform (Linux, macOS, Windows, BSD)
  # - Minimal resource usage
  # - Extensive configuration via TOML
  # - Vi mode for keyboard selection
  # - Active development and maintenance

  programs.alacritty = {
    enable = true;

    settings = {
      # Window configuration
      window = {
        # Transparency (matches previous ghostty config)
        opacity = 0.8;

        # Window decorations
        decorations = if pkgs.stdenv.isDarwin then "full" else "none";
      };

      # Cursor configuration
      cursor = {
        style = {
          shape = "Block";
          blinking = "Never";
        };
      };

      # Scrollback
      scrolling = {
        history = 100000;
      };

      # Clipboard
      selection = {
        save_to_clipboard = true;
      };

      # Gruvbox Dark color scheme - high contrast, readable
      colors = {
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };
        normal = {
          black = "#282828";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = "#a89984";
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          magenta = "#d3869b";
          cyan = "#8ec07c";
          white = "#ebdbb2";
        };
      };
    };
  };
}
