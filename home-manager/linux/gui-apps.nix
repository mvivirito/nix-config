{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

  programs.sioyek = {
    enable = true;
    config = {
      # Tokyo Night colors
      "background_color" = "0.102 0.106 0.149";        # #1a1b26
      "text_highlight_color" = "0.878 0.686 0.408";    # #e0af68 yellow
      "visual_mark_color" = "0.478 0.635 0.969 0.3";   # #7aa2f7 blue with alpha
      "search_highlight_color" = "1.0 0.620 0.392";    # #ff9e64 orange
      "status_bar_color" = "0.141 0.157 0.231";        # #24283b
      "status_bar_text_color" = "0.753 0.792 0.961";   # #c0caf5

      # Dark mode (invert) - toggle with 'i'
      "dark_mode_background_color" = "0.102 0.106 0.149";
      "dark_mode_contrast" = "0.8";

      # Custom color mode - toggle with Ctrl+R (better than invert for readability)
      "custom_background_color" = "0.102 0.106 0.149";  # #1a1b26
      "custom_text_color" = "0.753 0.792 0.961";        # #c0caf5

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
    obsidian         # Note-taking
    # sioyek configured via programs.sioyek above

    # File managers
    yazi             # Modern terminal file manager (Mod+Shift+R keybind)

    # System utilities
    blueman
    mission-center   # Modern GTK4 system monitor (Mod+Shift+M keybind)

    # Wayland clipboard tools
    wl-clipboard     # wl-copy/wl-paste for Wayland clipboard (needed by sioyek, etc.)
    wl-color-picker  # Wayland color picker utility
    wl-clip-persist  # Clipboard persistence across app closes

    # Wayland desktop components
    wlr-randr        # Display configuration tool

    # Audio/media control
    playerctl        # Media player controller (XF86Audio* keybinds)
    libqalculate     # Calculator backend

    # Dictation (handy speech-to-text app; PTT bound to PgDn via kanata in nixos/kanata)
    handy            # Tauri STT GUI app, toggle via `handy --toggle-transcription`
    wtype            # Wayland virtual-keyboard typing tool used by handy

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

  # handy: speech-to-text running hidden in the background.
  # Kanata fires `handy --toggle-transcription` on PgDn press and release
  # (see nixos/kanata) which signals this running instance to start/stop.
  systemd.user.services.handy = {
    Unit = {
      Description = "Handy speech-to-text";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.handy}/bin/handy --start-hidden";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
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
