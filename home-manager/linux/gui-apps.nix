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
    zathura          # Lightweight PDF viewer (SUPER+SHIFT+D keybind)

    # File managers
    xfce.thunar      # GUI file manager (SUPER+SHIFT+R keybind)
    xfce.tumbler     # Thumbnail support for Thunar
    # Note: ranger configured in core/ranger.nix

    # System utilities
    blueberry        # Bluetooth manager GUI
    mission-center   # Modern GTK4 system monitor (SUPER+SHIFT+M keybind)

    # X11/Wayland clipboard tools
    xclip            # X11 clipboard (legacy compatibility)
    xsel             # X11 selection (legacy compatibility)
    wl-color-picker  # Wayland color picker (SUPER+SHIFT+P keybind)
    wl-clip-persist  # Clipboard persistence across app closes

    # Screenshot tools
    grim             # Wayland screenshot capture (SUPER+Print keybind)
    slurp            # Region selector for grim

    # Wayland desktop components
    swaybg           # Wallpaper setter (alternative to hyprpaper)
    swayidle         # Idle manager (lock/sleep automation)
    swaylock         # Screen locker (SUPER+SHIFT+X keybind)
    swaynotificationcenter  # Notification daemon (SUPER+N keybind)
    waybar           # Status bar
    tofi             # Application launcher (SUPER+Space keybind)
    rofi-calc        # Calculator (SUPER+C keybind)
    rofimoji         # Emoji picker (SUPER+E keybind)
    wlr-randr        # Display configuration tool (used in display_layout.sh)

    # Desktop integration
    xdg-desktop-portal-hyprland  # File picker, screensharing support

    # Audio/media control
    playerctl        # Media player controller (XF86Audio* keybinds)
    libnotify        # Send desktop notifications
    libqalculate     # Calculator backend for rofi-calc

    # Clipboard management
    cliphist         # Clipboard history (SUPER+SHIFT+V keybind)
    polkit_gnome     # Authentication prompts for privileged actions
  ];
}
