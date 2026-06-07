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

      # Font configuration - use Nerd Font for icons (eza, etc.)
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 14;
      };

      # Scrollback
      scrolling = {
        history = 100000;
      };

      # Clipboard
      selection = {
        save_to_clipboard = true;
      };

      # Tokyo Night (Night) color scheme
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        selection = {
          text = "#c0caf5";
          background = "#283457";
        };
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
      };
    };
  };
}
