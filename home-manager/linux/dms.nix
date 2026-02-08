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
      # Theme: petrichor with blue variant
      currentThemeName = "custom";
      currentThemeCategory = "registry";
      customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/petrichor/theme.json";
      registryThemeVariants = {
        everforest = "soft";
        flexoki = "magenta";
        petrichor = "blue";
      };

      # Matugen: enable for terminal/app theming from wallpaper
      matugenScheme = "scheme-tonal-spot";
      runUserMatugenTemplates = true;
      runDmsMatugenTemplates = true;
      # Disabled - using consistent Gruvbox theme instead of wallpaper-generated colors
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

      # Power/idle (0 = disabled, rely on manual lock)
      acMonitorTimeout = 0;
      acLockTimeout = 0;
      batteryMonitorTimeout = 0;
      batteryLockTimeout = 0;
      lockBeforeSuspend = true;
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 5;
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;

      # Lock screen
      enableFprint = true;
      maxFprintTries = 15;

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
            "controlCenterButton"
          ];
          spacing = 4;
          innerPadding = 4;
          transparency = 1;
          widgetTransparency = 1;
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
