{ lib, pkgs, config, inputs, options, ... }:

let
  # Package paths for keybind commands
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

  # `claude-max` (the Mod+A launcher / `cy` alias YOLO wrapper) now lives in
  # home-manager/core/claude-max.nix so it installs on every Linux host — not
  # just niri desktops. Referenced by bare name below (it's on the profile PATH).

  pdf-picker = pkgs.writeShellScript "pdf-picker" ''
    selected=$(${pkgs.fd}/bin/fd --type f --extension pdf . "$HOME" 2>/dev/null | \
      ${pkgs.fzf}/bin/fzf --prompt="PDF> " --preview-window=hidden)
    if [ -n "$selected" ]; then
      # systemd-run detaches sioyek from terminal — setsid/disown fail because
      # alacritty -e tears down the process tree on script exit
      systemd-run --user -- ${pkgs.sioyek}/bin/sioyek "$selected"
    fi
  '';
in {
  # Note: niri is enabled at the system level in nixos/niri.nix
  # The niri NixOS module auto-imports homeModules.config for settings
  # We only configure settings here, not enable

  programs.niri.settings = {
      # Prefer server-side decorations (removes app title bars like sioyek's)
      prefer-no-csd = true;

      # Input configuration
      input = {
        keyboard = {
          xkb = {};
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          dwt = true;   # disable while typing
          dwtp = true;  # disable while trackpointing/using mouse
        };
        mouse = {
          accel-speed = 0.15;
        };
      };

      # Output (monitor) configuration
      # Ultrawide on left, laptop on right
      outputs = {
        "DP-3" = {
          mode = {
            width = 5120;
            height = 1440;
            refresh = 120.0;
          };
          position = {
            x = 0;
            y = 0;
          };
          scale = 1.0;
        };
        "eDP-1" = {
          mode = {
            width = 2160;
            height = 1350;
            refresh = 59.744;
          };
          position = {
            x = 5120;  # Right edge of ultrawide
            y = 166;   # Vertically centered
          };
          scale = 1.25;
        };
      };

      # Layout configuration
      layout = {
        gaps = 10;
        center-focused-column = "never";

        # Default column width (can be preset or fixed)
        default-column-width = {
          proportion = 0.5;  # Half screen by default
        };

        # Preset column widths for Mod+Shift+R cycling
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }  # 1/3 screen
          { proportion = 0.5; }        # 1/2 screen
          { proportion = 2.0 / 3.0; }  # 2/3 screen
          { proportion = 1.0; }        # Full width
        ];

        # Border — Tokyo Night gradient (blue → purple)
        border = {
          enable = true;
          width = 2;
          active.gradient = {
            from = "#7aa2f7";               # Tokyo Night blue
            to = "#bb9af7";                 # Tokyo Night purple
            angle = 45;
            relative-to = "workspace-view"; # gradient spans the whole view
          };
          inactive.color = "#2f3549";       # Tokyo Night surfaceVariant
        };

        # Focus ring (alternative to border) — off; border is used instead
        focus-ring = {
          enable = false;
        };
      };

      # Window rules
      window-rules = [
        # Firefox picture-in-picture
        {
          matches = [{ app-id = "firefox"; title = "Picture-in-Picture"; }];
          open-floating = true;
        }
        {
          matches = [{ app-id = "pdf-picker"; }];
          open-floating = true;
        }

        # Terminals: stop the gradient border bleeding through the transparent
        # background and tinting it. (Squared corners — no rounding.)
        {
          matches = [
            { app-id = "^Alacritty$"; }
            { app-id = "^kitty$"; }
          ];
          draw-border-with-background = false;
        }

        # Claude launcher (Mod+A): regular tiled terminal (blur via raw KDL below).
        {
          matches = [{ app-id = "claude-cli"; }];
          draw-border-with-background = false;
        }
      ];

      # Cursor settings
      cursor = {
        size = 32;
      };

      # Environment variables
      environment = {
        XCURSOR_SIZE = "32";
      };

      # Spawn at startup
      spawn-at-startup = [
      ];

      # Keybinds
      # Ported from Hyprland with niri-specific adaptations.
      #
      # Hotkey overlay (Mod+Slash) curation: niri's overlay shows every bind at
      # once and does NOT scroll, so the full list overflows the screen. To keep
      # it readable, the "look-it-up" binds (launchers, system actions, screenshots,
      # column features) carry a `hotkey-overlay.title` and stay visible, while the
      # rote navigation binds (vim/arrow focus & move, workspace numbers, monitor
      # switching, media/brightness keys, mouse wheel) set `hotkey-overlay.hidden`
      # so they're EXCLUDED from the overlay. Hidden binds still work normally.
      binds = {
        # ==========================================
        # Window management
        # ==========================================
        "Mod+Shift+Q".action.close-window = [];
        "Mod+Shift+Q".hotkey-overlay.title = "Close the focused window";
        "Mod+F".action.maximize-column = [];
        "Mod+F".hotkey-overlay.title = "Maximize column width (toggle)";
        "Mod+Shift+F".action.fullscreen-window = [];
        "Mod+Shift+F".hotkey-overlay.title = "Fullscreen the window (toggle)";
        "Mod+V".action.toggle-window-floating = [];
        "Mod+V".hotkey-overlay.title = "Toggle window floating / tiled";

        # ==========================================
        # Column/window focus (vim keys + arrows) — hidden from overlay
        # Niri uses horizontal scrolling columns
        # ==========================================
        "Mod+H".action.focus-column-left = [];
        "Mod+H".hotkey-overlay.hidden = true;
        "Mod+L".action.focus-column-right = [];
        "Mod+L".hotkey-overlay.hidden = true;
        "Mod+J".action.focus-window-down = [];
        "Mod+J".hotkey-overlay.hidden = true;
        "Mod+K".action.focus-window-up = [];
        "Mod+K".hotkey-overlay.hidden = true;
        "Mod+Left".action.focus-column-left = [];
        "Mod+Left".hotkey-overlay.hidden = true;
        "Mod+Right".action.focus-column-right = [];
        "Mod+Right".hotkey-overlay.hidden = true;
        "Mod+Down".action.focus-window-down = [];
        "Mod+Down".hotkey-overlay.hidden = true;
        "Mod+Up".action.focus-window-up = [];
        "Mod+Up".hotkey-overlay.hidden = true;

        # ==========================================
        # Column/window movement (vim keys + arrows) — hidden from overlay
        # ==========================================
        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+H".hotkey-overlay.hidden = true;
        "Mod+Shift+L".action.move-column-right = [];
        "Mod+Shift+L".hotkey-overlay.hidden = true;
        "Mod+Shift+J".action.move-window-down = [];
        "Mod+Shift+J".hotkey-overlay.hidden = true;
        "Mod+Shift+K".action.move-window-up = [];
        "Mod+Shift+K".hotkey-overlay.hidden = true;
        "Mod+Shift+Left".action.move-column-left = [];
        "Mod+Shift+Left".hotkey-overlay.hidden = true;
        "Mod+Shift+Right".action.move-column-right = [];
        "Mod+Shift+Right".hotkey-overlay.hidden = true;
        "Mod+Shift+Down".action.move-window-down = [];
        "Mod+Shift+Down".hotkey-overlay.hidden = true;
        "Mod+Shift+Up".action.move-window-up = [];
        "Mod+Shift+Up".hotkey-overlay.hidden = true;

        # ==========================================
        # Niri-specific column features
        # ==========================================
        "Mod+C".action.center-column = [];
        "Mod+C".hotkey-overlay.title = "Center the focused column";
        "Mod+Shift+R".action.switch-preset-column-width = [];
        "Mod+Shift+R".hotkey-overlay.title = "Cycle column width (1/3 -> 1/2 -> 2/3 -> full)";
        "Mod+E".action.expand-column-to-available-width = [];
        "Mod+E".hotkey-overlay.title = "Expand column to fill the free space";
        "Mod+W".action.toggle-column-tabbed-display = [];
        "Mod+W".hotkey-overlay.title = "Tab / untab the windows in this column";
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Comma".hotkey-overlay.title = "Pull the next window into this column";
        "Mod+Period".action.expel-window-from-column = [];
        "Mod+Period".hotkey-overlay.title = "Eject the focused window from this column";

        # Grow/shrink column width — hidden from overlay
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Minus".hotkey-overlay.hidden = true;
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Equal".hotkey-overlay.hidden = true;

        # ==========================================
        # Workspace navigation — hidden from overlay
        # Niri uses vertical workspace scrolling
        # ==========================================
        "Mod+Page_Down".action.focus-workspace-down = [];
        "Mod+Page_Down".hotkey-overlay.hidden = true;
        "Mod+Page_Up".action.focus-workspace-up = [];
        "Mod+Page_Up".hotkey-overlay.hidden = true;
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = [];
        "Mod+Shift+Page_Down".hotkey-overlay.hidden = true;
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = [];
        "Mod+Shift+Page_Up".hotkey-overlay.hidden = true;

        # Jump to a numbered workspace (Mod+1..0) — hidden from overlay
        "Mod+1".action.focus-workspace = 1;
        "Mod+1".hotkey-overlay.hidden = true;
        "Mod+2".action.focus-workspace = 2;
        "Mod+2".hotkey-overlay.hidden = true;
        "Mod+3".action.focus-workspace = 3;
        "Mod+3".hotkey-overlay.hidden = true;
        "Mod+4".action.focus-workspace = 4;
        "Mod+4".hotkey-overlay.hidden = true;
        "Mod+5".action.focus-workspace = 5;
        "Mod+5".hotkey-overlay.hidden = true;
        "Mod+6".action.focus-workspace = 6;
        "Mod+6".hotkey-overlay.hidden = true;
        "Mod+7".action.focus-workspace = 7;
        "Mod+7".hotkey-overlay.hidden = true;
        "Mod+8".action.focus-workspace = 8;
        "Mod+8".hotkey-overlay.hidden = true;
        "Mod+9".action.focus-workspace = 9;
        "Mod+9".hotkey-overlay.hidden = true;
        "Mod+0".action.focus-workspace = 10;
        "Mod+0".hotkey-overlay.hidden = true;

        # Send the focused column to a numbered workspace — hidden from overlay
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+1".hotkey-overlay.hidden = true;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+2".hotkey-overlay.hidden = true;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+3".hotkey-overlay.hidden = true;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+4".hotkey-overlay.hidden = true;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+5".hotkey-overlay.hidden = true;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+6".hotkey-overlay.hidden = true;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+7".hotkey-overlay.hidden = true;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+8".hotkey-overlay.hidden = true;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+9".hotkey-overlay.hidden = true;
        "Mod+Shift+0".action.move-column-to-workspace = 10;
        "Mod+Shift+0".hotkey-overlay.hidden = true;

        # ==========================================
        # Monitor navigation — hidden from overlay
        # ==========================================
        "Mod+BracketLeft".action.focus-monitor-left = [];
        "Mod+BracketLeft".hotkey-overlay.hidden = true;
        "Mod+BracketRight".action.focus-monitor-right = [];
        "Mod+BracketRight".hotkey-overlay.hidden = true;
        "Mod+Shift+BracketLeft".action.move-column-to-monitor-left = [];
        "Mod+Shift+BracketLeft".hotkey-overlay.hidden = true;
        "Mod+Shift+BracketRight".action.move-column-to-monitor-right = [];
        "Mod+Shift+BracketRight".hotkey-overlay.hidden = true;

        # Jump column to first/last on the workspace — hidden from overlay
        "Mod+Home".action.focus-column-first = [];
        "Mod+Home".hotkey-overlay.hidden = true;
        "Mod+End".action.focus-column-last = [];
        "Mod+End".hotkey-overlay.hidden = true;
        "Mod+Shift+Home".action.move-column-to-first = [];
        "Mod+Shift+Home".hotkey-overlay.hidden = true;
        "Mod+Shift+End".action.move-column-to-last = [];
        "Mod+Shift+End".hotkey-overlay.hidden = true;

        # Quick "go back" focus toggles — hidden from overlay
        "Mod+U".action.focus-workspace-previous = [];
        "Mod+U".hotkey-overlay.hidden = true;
        "Mod+P".action.focus-window-previous = [];
        "Mod+P".hotkey-overlay.hidden = true;

        # Less-used window tweaks — hidden from overlay
        "Mod+Shift+Return".action.toggle-windowed-fullscreen = [];
        "Mod+Shift+Return".hotkey-overlay.hidden = true;
        "Mod+Shift+C".action.center-visible-columns = [];
        "Mod+Shift+C".hotkey-overlay.hidden = true;
        "Mod+BackSpace".action.reset-window-height = [];
        "Mod+BackSpace".hotkey-overlay.hidden = true;

        # ==========================================
        # Overview mode (birds-eye view of workspaces)
        # ==========================================
        "Mod+Tab".action.toggle-overview = [];
        "Mod+Tab".hotkey-overlay.title = "Overview (zoom out to all workspaces)";

        # ==========================================
        # Application launchers
        # ==========================================
        "Mod+Return".action.spawn = [ "alacritty" ];
        "Mod+Return".hotkey-overlay.title = "Open a terminal (Alacritty)";
        "Mod+Space".action.spawn = [ "dms" "ipc" "call" "spotlight" "toggle" ];
        "Mod+Space".hotkey-overlay.title = "App launcher / search (Spotlight)";
        "Mod+B".action.spawn = [ "firefox" ];
        "Mod+B".hotkey-overlay.title = "Open the web browser (Firefox)";
        "Mod+D".action.spawn = [ "alacritty" "--class" "pdf-picker" "-e" "${pdf-picker}" ];
        "Mod+D".hotkey-overlay.title = "Find & open a PDF (fuzzy search)";
        "Mod+O".action.spawn = [ "1password" "--quick-access" ];
        "Mod+O".hotkey-overlay.title = "Open 1Password (quick access)";
        "Mod+Y".action.spawn = [ "alacritty" "-e" "nvim" ];
        "Mod+Y".hotkey-overlay.title = "Open Neovim (terminal editor)";
        "Mod+I".action.spawn = [ "code" ];
        "Mod+I".hotkey-overlay.title = "Open VS Code (editor)";
        "Mod+Z".action.spawn = [ "vlc" ];
        "Mod+Z".hotkey-overlay.title = "Open VLC (media player)";
        "Mod+N".action.spawn = [ "obsidian" ];
        "Mod+N".hotkey-overlay.title = "Open Obsidian (notes vault)";
        "Mod+T".action.spawn = [ "Telegram" ];
        "Mod+T".hotkey-overlay.title = "Open Telegram";
        "Mod+R".action.spawn = [ "alacritty" "-e" "yazi" ];
        "Mod+R".hotkey-overlay.title = "Open the file manager (Yazi)";

        # ==========================================
        # System tools
        # ==========================================
        "Mod+Shift+M".action.spawn = [ "missioncenter" ];
        "Mod+Shift+M".hotkey-overlay.title = "Open the system monitor (Mission Center)";
        "Mod+Shift+Y".action.spawn = [ "alacritty" "-e" "btop" ];
        "Mod+Shift+Y".hotkey-overlay.title = "Open the process monitor (btop)";
        "Mod+Shift+E".action.quit = [];
        "Mod+Shift+E".hotkey-overlay.title = "Quit niri (log out of the session)";
        "Super+Alt+L".action.spawn = [ "loginctl" "lock-session" ];
        "Super+Alt+L".hotkey-overlay.title = "Lock the screen";
        "Mod+Shift+P".action.spawn = [ "dms" "ipc" "call" "powermenu" "toggle" ];
        "Mod+Shift+P".hotkey-overlay.title = "Power menu (shutdown / reboot / sleep / log out)";
        "Mod+Shift+V".action.spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
        "Mod+Shift+V".hotkey-overlay.title = "Clipboard history";
        "Mod+Shift+D".action.spawn = [ "discord" ];
        "Mod+Shift+D".hotkey-overlay.title = "Open Discord";

        # Dictation (handy) — PTT is bound to PgDn at the kanata level,
        # see nixos/kanata/default.nix. No niri binding needed.

        # ==========================================
        # Screenshots (DMS native)
        # --no-file = clipboard only; --no-clipboard = save file only
        # (saved to ~/Pictures/Screenshots via screenshot-path)
        # ==========================================
        "Mod+G".action.spawn = [ "dms" "screenshot" "--no-file" ];
        "Mod+G".hotkey-overlay.title = "Screenshot a region -> copy to clipboard";
        "Mod+Shift+G".action.spawn = [ "dms" "screenshot" "full" "--no-file" ];
        "Mod+Shift+G".hotkey-overlay.title = "Screenshot the whole screen -> copy to clipboard";
        "Mod+Print".action.spawn = [ "dms" "screenshot" "--no-clipboard" ];
        "Mod+Print".hotkey-overlay.title = "Screenshot a region -> save to Pictures";
        "Mod+Shift+Print".action.spawn = [ "dms" "screenshot" "full" "--no-clipboard" ];
        "Mod+Shift+Print".hotkey-overlay.title = "Screenshot the whole screen -> save to Pictures";

        # ==========================================
        # Media keys — hidden from overlay (labeled physical keys)
        # ==========================================
        "XF86AudioRaiseVolume".action.spawn = [ "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
        "XF86AudioRaiseVolume".hotkey-overlay.hidden = true;
        "XF86AudioLowerVolume".action.spawn = [ "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
        "XF86AudioLowerVolume".hotkey-overlay.hidden = true;
        "XF86AudioMute".action.spawn = [ "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        "XF86AudioMute".hotkey-overlay.hidden = true;
        "XF86AudioPlay".action.spawn = [ "${playerctl}" "play-pause" ];
        "XF86AudioPlay".hotkey-overlay.hidden = true;
        "XF86AudioPause".action.spawn = [ "${playerctl}" "play-pause" ];
        "XF86AudioPause".hotkey-overlay.hidden = true;
        "XF86AudioNext".action.spawn = [ "${playerctl}" "next" ];
        "XF86AudioNext".hotkey-overlay.hidden = true;
        "XF86AudioPrev".action.spawn = [ "${playerctl}" "previous" ];
        "XF86AudioPrev".hotkey-overlay.hidden = true;
        "XF86MonBrightnessDown".action.spawn = [ "${brightnessctl}" "set" "5%-" ];
        "XF86MonBrightnessDown".hotkey-overlay.hidden = true;
        "XF86MonBrightnessUp".action.spawn = [ "${brightnessctl}" "set" "+5%" ];
        "XF86MonBrightnessUp".hotkey-overlay.hidden = true;

        # ==========================================
        # Mouse binds — hidden from overlay
        # ==========================================
        "Mod+WheelScrollDown".action.focus-workspace-down = [];
        "Mod+WheelScrollDown".hotkey-overlay.hidden = true;
        "Mod+WheelScrollUp".action.focus-workspace-up = [];
        "Mod+WheelScrollUp".hotkey-overlay.hidden = true;

        # ==========================================
        # Claude — Mod+A ("Ask"): terminal running
        # `claude --dangerously-skip-permissions --effort max`
        # ==========================================
        "Mod+A".action.spawn = [ "${pkgs.alacritty}/bin/alacritty" "--class" "claude-cli" "-e" "claude-max" ];
        "Mod+A".hotkey-overlay.title = "Open Claude (skip permissions, max effort)";

        # ==========================================
        # Discoverability
        # ==========================================
        "Mod+Slash".action.show-hotkey-overlay = [];
        "Mod+Slash".hotkey-overlay.title = "Show this keybind cheat sheet";
      };

      # Hotkey overlay (show available keybinds)
      hotkey-overlay = {
        skip-at-startup = true;
      };

      # Screenshot configuration
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

      # Animations — snappy. Use niri's built-in defaults (springs for
      # movement/resize/view, quick easings for open/close) by leaving the
      # block unset. To slow everything down, set `animations.slowdown = 1.5;`.
      animations = {
        enable = true;
      };
    };

  # Background blur (niri 26.04). The pinned niri-flake rev exposes no typed
  # `blur` / `background-effect` option, so inject it as raw KDL appended to the
  # settings-rendered config (xray blur = cheap see-through-to-wallpaper). Blur is
  # only visible where a surface is semi-transparent — the terminals already are.
  # niri-flake's rendered config is a KDL-document (node list), so serialize it
  # to a string before appending the raw blur KDL.
  programs.niri.config = lib.mkForce (
    let
      rendered = options.programs.niri.config.default;
      base =
        if builtins.isString rendered
        then rendered
        else inputs.niri.lib.kdl.serialize.nodes rendered;
    in base + ''

    blur {
        passes 3
        offset 3.0
        noise 0.02
        saturation 1.2
    }

    window-rule {
        match app-id="^Alacritty$"
        background-effect {
            blur true
        }
    }
    window-rule {
        match app-id="^kitty$"
        background-effect {
            blur true
        }
    }
    window-rule {
        match app-id="^claude-cli$"
        background-effect {
            blur true
        }
    }
  '');

  # Required packages for niri keybinds
  home.packages = [
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.wireplumber  # For wpctl
  ];
}
