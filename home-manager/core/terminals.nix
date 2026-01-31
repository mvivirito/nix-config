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

      # Font (optional - alacritty has good defaults)
      # font = {
      #   normal = {
      #     family = "JetBrainsMono Nerd Font";
      #   };
      #   size = 12.0;
      # };
    };
  };
}
