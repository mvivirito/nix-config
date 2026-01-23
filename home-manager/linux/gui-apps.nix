{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

  home.packages = with pkgs; [
    # Browsers
    firefox
    floorp-bin

    # Communication
    discord

    # Media
    spotify
    vlc
    webcamoid        # Webcam application

    # Productivity
    vscode           # Code editor (has macOS version but configured here)
    zathura          # PDF viewer
    aerc             # Email client

    # File managers and utilities
    xfce.thunar      # File manager
    xfce.tumbler     # Thumbnail generator for Thunar
    ranger           # Terminal file manager (configured separately)

    # System utilities
    blueberry             # Bluetooth manager
    nwg-displays          # Display configuration tool

    # Wayland/X11 tools
    xclip            # X11 clipboard
    xsel             # X11 selection
    wl-clipboard     # Wayland clipboard
    wl-color-picker  # Color picker for Wayland
    wl-clip-persist  # Clipboard persistence

    # Screenshot and screen tools
    grim             # Screenshot utility
    slurp            # Region selector
    wev              # Wayland event viewer
    wshowkeys        # Show keypresses on screen

    # Wayland desktop components
    swaybg                      # Wallpaper setter
    swayidle                    # Idle manager
    swaylock                    # Screen locker
    swaynotificationcenter      # Notification daemon
    waybar                      # Status bar
    tofi                        # Application launcher
    rofi-calc                   # Calculator for rofi
    rofimoji                    # Emoji picker
    wlr-randr                   # Display configuration

    # Desktop portal
    xdg-desktop-portal-hyprland

    # Audio/media control
    playerctl        # Media player controller
    libnotify        # Notification library
    libqalculate     # Calculator library

    # Additional utilities
    cliphist         # Clipboard history manager
    polkit_gnome     # Authentication agent
  ];
}
