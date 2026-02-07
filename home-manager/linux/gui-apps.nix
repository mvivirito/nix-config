{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

  programs.sioyek = {
    enable = true;
    config = {
      # Catppuccin Mocha colors
      "background_color" = "0.12 0.12 0.18";
      "text_highlight_color" = "0.98 0.89 0.68";
      "visual_mark_color" = "0.54 0.71 0.98 0.3";
      "search_highlight_color" = "0.98 0.89 0.68";
      "status_bar_color" = "0.12 0.12 0.18";
      "status_bar_text_color" = "0.80 0.84 0.96";

      # Dark mode (invert) - toggle with 'i'
      "dark_mode_background_color" = "0.12 0.12 0.18";
      "dark_mode_contrast" = "0.8";

      # Custom color mode - toggle with Ctrl+R (better than invert for readability)
      # Catppuccin Mocha: base background, text foreground
      "custom_background_color" = "0.12 0.12 0.18";
      "custom_text_color" = "0.80 0.84 0.96";

      # Wayland clipboard integration
      "copy_command" = "wl-copy";
    };
    bindings = {
      # Vim-style horizontal scrolling
      "move_left" = "h";
      "move_right" = "l";

      # Dark mode toggle
      "toggle_custom_color" = "<C-r>";
    };
  };

  home.packages = with pkgs; [
    # Browsers - testing multiple options
    floorp-bin       # Firefox fork with vertical tabs (experimental)

    # Communication
    discord

    # Media
    spotify
    vlc

    # Productivity
    vscode           # Primary code editor (alongside neovim)
    # sioyek configured via programs.sioyek above

    # File managers
    yazi             # Modern terminal file manager (Mod+Shift+R keybind)

    # System utilities
    blueberry        # Bluetooth manager GUI
    mission-center   # Modern GTK4 system monitor (Mod+Shift+M keybind)
    trayscale        # Tailscale systray GUI (appears in DMS system tray)

    # Wayland clipboard tools
    wl-clipboard     # wl-copy/wl-paste for Wayland clipboard (needed by sioyek, etc.)
    wl-color-picker  # Wayland color picker utility
    wl-clip-persist  # Clipboard persistence across app closes

    # Wayland desktop components
    wlr-randr        # Display configuration tool

    # Desktop integration
    xdg-desktop-portal-wlr  # File picker, screensharing for wlroots compositors (Niri)

    # Audio/media control
    playerctl        # Media player controller (XF86Audio* keybinds)
    libqalculate     # Calculator backend

    # Dictation
    whisper-cpp      # Speech-to-text via whisper model
    ydotool          # Virtual keyboard input for typing transcriptions

    # Note: Bar, launcher, notifications, lock screen, clipboard, and screenshots
    # are all provided by DMS (Dank Material Shell) - see linux/dms.nix
  ];
}
