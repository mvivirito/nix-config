{ inputs, pkgs, config, ... }:

{
  # Import DMS home-manager modules
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri  # Niri-specific integration
  ];

  # Dank Material Shell configuration
  # Replaces: waybar, swaylock, swayidle, swaync, tofi/rofi, polkit agent
  #
  # DMS uses matugen for dynamic wallpaper-based theming
  # Colors are generated from your wallpaper automatically
  programs.dank-material-shell = {
    enable = true;

    # Niri-specific integration
    niri = {
      enableKeybinds = false;  # Disabled - we define our own keybinds in niri/default.nix
      enableSpawn = false;     # Disabled - using systemd instead (spawn-at-startup fails with greetd)
      includes.enable = false; # Disabled - niri doesn't support DMS's KDL includes (causes parse errors)
    };

    # Use systemd for starting DMS (more reliable with greetd)
    systemd.enable = true;

    # Enable system monitoring (CPU, RAM, etc. in bar)
    enableSystemMonitoring = true;

    # DMS settings (written to ~/.config/DankMaterialShell/settings.json)
    # These are the main DMS configuration options
    settings = {
      # Lock screen before suspend (lid close, power button, etc.)
      lockBeforeSuspend = true;

      # Lock screen timeout (in seconds)
      lockTimeout = 900;  # 15 minutes

      # DPMS timeout (in seconds)
      dpmsTimeout = 930;  # 15.5 minutes

      # Bar position
      barPosition = "top";

      # Show system tray in bar (ensure tray icons like trayscale are visible)
      showSystemTray = true;
    };

    # Clipboard settings
    clipboardSettings = {
      # Clipboard history length
      maxItems = 100;
    };
  };

  # Override DMS systemd service to fix Qt platform plugin issue
  # The DMS wrapper sets QT_PLUGIN_PATH but doesn't include qtbase's platforms/
  # This causes quickshell to fail with "cannot open display" error
  systemd.user.services.dms.Service.Environment = [
    "QT_QPA_PLATFORM=wayland"
    # Prepend qtbase plugins (contains libqwayland.so platform plugin)
    # This will be prepended to the wrapper's QT_PLUGIN_PATH
    "QT_PLUGIN_PATH=${pkgs.kdePackages.qtbase}/lib/qt-6/plugins"
  ];

  # Trayscale systemd service - starts after DMS so the SNI tray host is ready
  # Note: Cannot use Requires=dms.service as it creates an ordering cycle:
  # graphical-session.target → trayscale → dms → graphical-session.target
  systemd.user.services.trayscale = {
    Unit = {
      Description = "Trayscale Tailscale tray icon";
      After = [ "dms.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.trayscale}/bin/trayscale --hide-window";
      Restart = "on-failure";
      RestartSec = 5;
      RestartMaxDelaySec = "30";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Required packages for DMS/quickshell
  home.packages = with pkgs; [
    kdePackages.qtwayland  # Qt6 Wayland support libraries
    xwayland-satellite     # XWayland support for niri (for X11 fallback)
  ];
}
