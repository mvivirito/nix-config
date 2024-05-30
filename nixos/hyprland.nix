{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {

    services.xserver.displayManager.startx.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    security = {
      polkit.enable = true;
      pam.services.ags = {};
    };

    environment.systemPackages = with pkgs;
    with gnome; [
      loupe
      baobab
      gnome-text-editor
      gnome-boxes
      gnome-system-monitor
      gnome-control-center
      gnome-weather
      gnome-calculator
      gnome-clocks
      wl-gammactl
      wl-clipboard
      wayshot
      pavucontrol
      brightnessctl
      swww
    ];

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    services = {
      gvfs.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
      accounts-daemon.enable = true;
      gnome = {
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-online-accounts.enable = true;
      };
    };
}

