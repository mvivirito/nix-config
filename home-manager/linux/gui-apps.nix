{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

  programs.sioyek = {
    enable = true;
    config = {
      # Gruvbox Dark colors - high contrast, readable
      "background_color" = "0.16 0.16 0.16";           # #282828
      "text_highlight_color" = "0.84 0.60 0.13";       # #d79921 yellow
      "visual_mark_color" = "0.27 0.52 0.53 0.3";      # #458588 blue with alpha
      "search_highlight_color" = "0.98 0.74 0.18";     # #fabd2f bright yellow
      "status_bar_color" = "0.20 0.20 0.20";           # slightly lighter than bg
      "status_bar_text_color" = "0.92 0.86 0.70";      # #ebdbb2

      # Dark mode (invert) - toggle with 'i'
      "dark_mode_background_color" = "0.16 0.16 0.16";
      "dark_mode_contrast" = "0.8";

      # Custom color mode - toggle with Ctrl+R (better than invert for readability)
      "custom_background_color" = "0.16 0.16 0.16";    # #282828
      "custom_text_color" = "0.92 0.86 0.70";          # #ebdbb2

      # Wayland clipboard integration
      "copy_command" = "wl-copy";
    };
    bindings = {
      # Reversed vim-style horizontal scrolling
      "move_left" = "l";
      "move_right" = "h";

      # Dark mode toggle
      "toggle_custom_color" = "<C-r>";
    };
  };

  home.packages = with pkgs; [
    # Browsers - testing multiple options
    floorp-bin       # Firefox fork with vertical tabs (experimental)

    # Communication
    discord
    telegram-desktop

    # Media
    imv              # Lightweight Wayland image viewer
    mpv              # Lightweight video player (keyboard-driven)
    moonlight-qt
    spotify
    vlc

    # Productivity
    vscode           # Primary code editor (alongside neovim)
    # sioyek configured via programs.sioyek above

    # File managers
    yazi             # Modern terminal file manager (Mod+Shift+R keybind)

    # System utilities
<<<<<<< HEAD
    blueman          # Bluetooth manager GUI
||||||| parent of 4d00687 (bluetooth and wine update)
    blueberry        # Bluetooth manager GUI
=======
    blueman
>>>>>>> 4d00687 (bluetooth and wine update)
    mission-center   # Modern GTK4 system monitor (Mod+Shift+M keybind)

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

    # DMS integration
    dsearch          # Filesystem search for DMS spotlight

    # Note: Bar, launcher, notifications, lock screen, clipboard, and screenshots
    # are all provided by DMS (Dank Material Shell) - see linux/dms.nix
  ];

  # dsearch: indexed filesystem search for DMS spotlight file results
  systemd.user.services.dsearch = {
    Unit.Description = "dsearch filesystem indexer";
    Service = {
      ExecStart = "${pkgs.dsearch}/bin/dsearch serve";
      Restart = "on-failure";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "dsearch";
    };
    Install.WantedBy = [ "default.target" ];
  };

  xdg.configFile."danksearch/config.toml".text = ''
    listen_addr = ":43654"
    index_all_files = true
    max_file_bytes = 2097152

    [[index_paths]]
    path = "/home/michael"
    max_depth = 6
    exclude_hidden = true
    extract_exif = true
    exclude_dirs = [
      "node_modules", "__pycache__", "venv", ".venv",
      "target", "dist", "build", "vendor", ".cache",
      ".local", ".nix-defexpr", ".nix-profile"
    ]
  '';
}
