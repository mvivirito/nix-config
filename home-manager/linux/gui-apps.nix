{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

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
    zathura          # Lightweight PDF viewer (Mod+Shift+D keybind)

    # File managers
    yazi             # Modern terminal file manager (Mod+Shift+R keybind)

    # System utilities
    blueberry        # Bluetooth manager GUI
    mission-center   # Modern GTK4 system monitor (Mod+Shift+M keybind)

    # Wayland clipboard tools
    wl-color-picker  # Wayland color picker utility
    wl-clip-persist  # Clipboard persistence across app closes

    # Wayland desktop components
    wlr-randr        # Display configuration tool

    # Desktop integration
    xdg-desktop-portal-wlr  # File picker, screensharing for wlroots compositors (Niri)

    # Audio/media control
    playerctl        # Media player controller (XF86Audio* keybinds)
    libqalculate     # Calculator backend

    # Note: Bar, launcher, notifications, lock screen, clipboard, and screenshots
    # are all provided by DMS (Dank Material Shell) - see linux/dms.nix
  ];
}
