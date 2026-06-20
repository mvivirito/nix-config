{ inputs, pkgs, config, ... }:

{
  # Import DMS home-manager modules
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri  # Niri-specific integration
  ];

  # Dank Material Shell configuration
  # Replaces: waybar, swaylock, swayidle, swaync, tofi/rofi, polkit agent
  programs.dank-material-shell = {
    enable = true;

    # Niri-specific integration
    niri = {
      enableKeybinds = false;  # We define our own keybinds in niri/default.nix
      enableSpawn = false;     # Using systemd instead (spawn-at-startup fails with greetd)
      includes.enable = false; # Niri doesn't support DMS's KDL includes
    };

    systemd.enable = true;
    enableSystemMonitoring = true;

    settings = {
      # Theme: Tokyo Night (vibrant blues/purples; matches terminals + niri border)
      currentThemeName = "tokyoNight";
      currentThemeCategory = "registry";
      registryThemeVariants = {
        everforest = "soft";
        flexoki = "magenta";
        petrichor = "blue";
      };

      # Matugen: enable for terminal/app theming from wallpaper
      matugenScheme = "scheme-tonal-spot";
      runUserMatugenTemplates = true;
      runDmsMatugenTemplates = true;
      # Disabled - using the fixed Tokyo Night theme instead of wallpaper-generated colors
      matugenTemplateAlacritty = false;
      matugenTemplateFirefox = false;
      matugenTemplateNeovim = false;
      matugenTemplateKitty = false;
      matugenTemplateVscode = false;
      # Disable unused matugen templates
      matugenTemplateGtk = false;  # home-manager handles GTK
      matugenTemplateNiri = false; # niri config is in home-manager
      matugenTemplateHyprland = false;
      matugenTemplateMangowc = false;
      matugenTemplateQt5ct = false;
      matugenTemplateQt6ct = false;
      matugenTemplatePywalfox = false;
      matugenTemplateZenBrowser = false;
      matugenTemplateVesktop = false;
      matugenTemplateEquibop = false;
      matugenTemplateGhostty = false;
      matugenTemplateFoot = false;
      matugenTemplateWezterm = false;
      matugenTemplateDgop = false;
      matugenTemplateKcolorscheme = false;

      # Appearance
      widgetColorMode = "colorful";
      cornerRadius = 12;

      # Frosted glass — translucent surfaces + real backdrop blur.
      # (blur verified supported on this niri 26.04 via `dms blur check`)
      blurEnabled = true;
      blurForegroundLayers = true;
      popupTransparency = 0.92;  # control center / popout menus (1.0 = opaque)

      # Time/locale
      use24HourClock = false;
      useFahrenheit = true;

      # Bar widgets
      showSystemTray = true;
      showCpuUsage = true;
      showMemUsage = true;
      showCpuTemp = true;
      showGpuTemp = true;

      # App ID substitutions (for correct icons)
      appIdSubstitutions = [
        { pattern = "Alacritty"; replacement = "com.alacritty.Alacritty"; type = "contains"; }
        { pattern = "sioyek"; replacement = "sioyek"; type = "contains"; }
        { pattern = "Spotify"; replacement = "spotify"; type = "exact"; }
        { pattern = "^steam_app_(\\d+)$"; replacement = "steam_icon_$1"; type = "regex"; }
      ];

      # Spotlight/launcher
      appLauncherViewMode = "list";
      spotlightModalViewMode = "list";
      spotlightCloseNiriOverview = true;
      niriOverviewOverlayEnabled = true;

      # Power/idle. On AC: never blank/lock (desk use). On battery: blank the
      # display after 3 min and lock after 5 min (battery + security).
      #
      # Idle sleep: after 10 min idle with the lid OPEN, DMS runs
      # `systemctl suspend-then-hibernate` (IdleService -> SessionService) on
      # BOTH AC and battery -> light sleep, then hibernate after HibernateDelaySec
      # (15 min; see hosts/nixos/shared/hibernate.nix). Charging must not block it.
      # DMS SuspendBehavior enum: 0=Suspend, 1=Hibernate, 2=SuspendThenHibernate.
      acMonitorTimeout = 0;
      acLockTimeout = 0;
      acSuspendTimeout = 600;       # 10 min idle -> suspend-then-hibernate (AC too)
      acSuspendBehavior = 2;        # SuspendThenHibernate
      batteryMonitorTimeout = 180;
      batteryLockTimeout = 300;
      batterySuspendTimeout = 600;  # 10 min idle -> suspend-then-hibernate
      batterySuspendBehavior = 2;   # SuspendThenHibernate
      lockBeforeSuspend = true;
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 5;
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;

      # Lock screen
      enableFprint = false;

      # Sounds
      soundsEnabled = true;

      # Notifications
      notificationHistoryEnabled = true;
      notificationHistoryMaxCount = 50;

      # Bar config
      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0;  # top
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            "focusedWindow"
            { id = "runningApps"; enabled = true; }
          ];
          centerWidgets = [ "clock" ];
          rightWidgets = [
            "systemTray"
            { id = "tailscale"; enabled = true; }  # dms-tailscale plugin
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "battery"
            "idleInhibitor"  # caffeine: click to toggle keep-awake (SessionService.toggleIdleInhibit)
            "controlCenterButton"
          ];
          spacing = 4;
          innerPadding = 4;
          transparency = 0.82;        # bar strip alpha (1.0 = opaque, 0.0 = clear)
          widgetTransparency = 0.78;  # per-widget pill alpha
          visible = true;
        }
      ];

      # Fonts
      fontFamily = "Inter Variable";
      monoFontFamily = "Fira Code";

      configVersion = 5;
    };

    clipboardSettings.maxItems = 100;
  };

  systemd.user.services.dms.Service.Environment = [
    "QT_QPA_PLATFORM=wayland"
    "QT_PLUGIN_PATH=${pkgs.kdePackages.qtbase}/lib/qt-6/plugins"
  ];

  home.packages = with pkgs; [
    kdePackages.qtwayland
    xwayland-satellite
  ];
}
