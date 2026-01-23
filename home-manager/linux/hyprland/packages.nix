{ pkgs, ... }:

{
  # Hyprland-related packages (user-level)
  home.packages = with pkgs; with pkgs.gnome; [
    loupe              # Image viewer (GNOME but works on Hyprland)
    gnome-text-editor  # Text editor (GNOME but works on Hyprland)
    wl-clipboard       # Wayland clipboard utilities (used in keybinds)
    pavucontrol        # Audio control GUI (SUPER+SHIFT+B keybind)
    brightnessctl      # Backlight control (XF86MonBrightness* keybinds)
  ];

  # Polkit authentication agent (user service)
  # Provides password prompts for privileged operations
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
