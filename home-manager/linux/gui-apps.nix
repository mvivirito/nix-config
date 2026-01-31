{ pkgs, ... }:

{
  # Linux-specific GUI applications and desktop tools
  # These packages are Wayland/X11 dependent and won't work on macOS

  programs.zathura = {
    enable = true;
    options = {
      # Catppuccin Mocha colors
      default-bg = "#1e1e2e";
      default-fg = "#cdd6f4";
      statusbar-bg = "#1e1e2e";
      statusbar-fg = "#cdd6f4";
      inputbar-bg = "#1e1e2e";
      inputbar-fg = "#cdd6f4";
      notification-bg = "#1e1e2e";
      notification-fg = "#cdd6f4";
      notification-error-bg = "#1e1e2e";
      notification-error-fg = "#f38ba8";
      notification-warning-bg = "#1e1e2e";
      notification-warning-fg = "#fab387";
      highlight-color = "#f9e2af";
      highlight-active-color = "#89b4fa";
      completion-bg = "#313244";
      completion-fg = "#cdd6f4";
      completion-highlight-bg = "#45475a";
      completion-highlight-fg = "#cdd6f4";
      recolor-lightcolor = "#1e1e2e";
      recolor-darkcolor = "#cdd6f4";
      recolor = true;
      recolor-keephue = true;
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
    # zathura configured via programs.zathura below

    # File managers
    yazi             # Modern terminal file manager (Mod+Shift+R keybind)

    # System utilities
    blueberry        # Bluetooth manager GUI
    mission-center   # Modern GTK4 system monitor (Mod+Shift+M keybind)
    trayscale        # Tailscale systray GUI (appears in DMS system tray)

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
