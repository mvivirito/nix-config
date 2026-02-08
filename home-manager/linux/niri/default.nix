{ lib, pkgs, config, inputs, ... }:

let
  # Package paths for keybind commands
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

  # Dictation toggle script: first press starts recording, second press stops and transcribes
  notify = "${pkgs.libnotify}/bin/notify-send";

  dictation-toggle = pkgs.writeShellScript "dictation-toggle" ''
    export YDOTOOL_SOCKET="$XDG_RUNTIME_DIR/.ydotool_socket"
    PIDFILE="$XDG_RUNTIME_DIR/dictation-stream.pid"
    MODEL="$HOME/.local/share/whisper-cpp/ggml-medium.en.bin"

    if [ -f "$PIDFILE" ]; then
      # Kill the whole process group (whisper-stream + pipe)
      kill -- -"$(cat "$PIDFILE")" 2>/dev/null
      rm "$PIDFILE"
      ${notify} -u low -t 2000 -a Dictation "Dictation" "Stopped"
    else
      # Download model on first use
      if [ ! -f "$MODEL" ]; then
        mkdir -p "$(dirname "$MODEL")"
        ${notify} -u low -t 0 -a Dictation "Dictation" "Downloading model..."
        ${pkgs.whisper-cpp}/bin/whisper-cpp-download-ggml-model medium.en
        mv ggml-medium.en.bin "$MODEL"
      fi
      ${notify} -u low -t 2000 -a Dictation "Dictation" "Listening..."
      # Run in a new process group so we can kill everything on stop
      setsid bash -c '
        ${pkgs.whisper-cpp}/bin/whisper-stream \
          -m "'"$MODEL"'" \
          --step 3000 \
          --length 5000 \
          -t 4 \
          --no-fallback \
          2>/dev/null | \
        sed -u "s/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//g; s/^ *//; s/ *$//" | \
        grep -v --line-buffered -E "^\[|^$" | \
        while IFS= read -r line; do
          if [ -n "$line" ]; then
            ${pkgs.ydotool}/bin/ydotool type -- "$line"
          fi
        done
      ' &
      echo $! > "$PIDFILE"
    fi
  '';

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

  # Disable niri-flake's polkit agent - DMS provides its own
  systemd.user.services.niri-flake-polkit.Install.WantedBy = lib.mkForce [];

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
          dwt = true;  # disable while typing
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

        # Border colors (Gruvbox Dark)
        border = {
          enable = true;
          width = 1;
          active.color = "#83a598";    # Gruvbox bright blue
          inactive.color = "#3c3836";  # Gruvbox bg1
        };

        # Focus ring (alternative to border)
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
      # Ported from Hyprland with niri-specific adaptations
      binds = {
        # ==========================================
        # Window management
        # ==========================================
        "Mod+Shift+Q".action.close-window = [];
        "Mod+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];
        "Mod+V".action.toggle-window-floating = [];

        # ==========================================
        # Column/window focus (vim keys)
        # Niri uses horizontal scrolling columns
        # ==========================================
        "Mod+H".action.focus-column-left = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];

        # Arrow key variants
        "Mod+Left".action.focus-column-left = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+Up".action.focus-window-up = [];

        # ==========================================
        # Column/window movement
        # ==========================================
        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+L".action.move-column-right = [];
        "Mod+Shift+J".action.move-window-down = [];
        "Mod+Shift+K".action.move-window-up = [];

        # Arrow key variants
        "Mod+Shift+Left".action.move-column-left = [];
        "Mod+Shift+Right".action.move-column-right = [];
        "Mod+Shift+Down".action.move-window-down = [];
        "Mod+Shift+Up".action.move-window-up = [];

        # ==========================================
        # Niri-specific column features
        # ==========================================
        # Center column (great for ultrawide)
        "Mod+C".action.center-column = [];

        # Switch column width presets (1/3, 1/2, 2/3, full)
        "Mod+Shift+R".action.switch-preset-column-width = [];

        # Grow/shrink column width
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Consume/expel windows to/from column
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Period".action.expel-window-from-column = [];

        # ==========================================
        # Workspace navigation
        # Niri uses vertical workspace scrolling
        # ==========================================
        "Mod+Page_Down".action.focus-workspace-down = [];
        "Mod+Page_Up".action.focus-workspace-up = [];
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = [];
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = [];

        # Workspace numbers (1-10, like hyprland)
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;

        # Move to workspace numbers
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+0".action.move-column-to-workspace = 10;

        # ==========================================
        # Monitor navigation
        # ==========================================
        "Mod+BracketLeft".action.focus-monitor-left = [];
        "Mod+BracketRight".action.focus-monitor-right = [];
        "Mod+Shift+BracketLeft".action.move-column-to-monitor-left = [];
        "Mod+Shift+BracketRight".action.move-column-to-monitor-right = [];

        # ==========================================
        # Overview mode (birds-eye view of workspaces)
        # ==========================================
        "Mod+Tab".action.toggle-overview = [];

        # ==========================================
        # Application launchers
        # Alacritty terminal
        # ==========================================
        "Mod+Return".action.spawn = [ "alacritty" ];
        # DMS spotlight (app launcher)
        "Mod+Space".action.spawn = [ "dms" "ipc" "call" "spotlight" "toggle" ];
        "Mod+B".action.spawn = [ "firefox" ];
        "Mod+D".action.spawn = [ "alacritty" "--class" "pdf-picker" "-e" "${pdf-picker}" ];
        "Mod+O".action.spawn = [ "1password" "--quick-access" ];
        "Mod+Y".action.spawn = [ "alacritty" "-e" "nvim" ];
        "Mod+I".action.spawn = [ "code" ];
        "Mod+Z".action.spawn = [ "vlc" ];
        # Yazi file manager in terminal
        "Mod+R".action.spawn = [ "alacritty" "-e" "yazi" ];

        # ==========================================
        # System tools
        # ==========================================
        "Mod+Shift+M".action.spawn = [ "missioncenter" ];
        "Mod+Shift+Y".action.spawn = [ "alacritty" "-e" "htop" ];
        "Mod+Shift+E".action.quit = [];  # Exit niri

        # DMS power menu (shutdown, reboot, sleep, logout)
        "Mod+Shift+P".action.spawn = [ "dms" "ipc" "call" "powermenu" "toggle" ];

        # DMS clipboard history
        "Mod+Shift+V".action.spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];

        "Mod+Shift+D".action.spawn = [ "discord" ];

        # ==========================================
        # Dictation (whisper-cpp)
        # ==========================================
        "Mod+N".action.spawn = [ "${dictation-toggle}" ];

        # ==========================================
        # Screenshots (DMS native)
        # ==========================================
        "Mod+G".action.spawn = [ "dms" "screenshot" "--no-file" ];
        "Mod+Shift+G".action.spawn = [ "dms" "screenshot" "full" "--no-file" ];
        "Mod+Print".action.spawn = [ "dms" "screenshot" "--no-clipboard" ];
        "Mod+Shift+Print".action.spawn = [ "dms" "screenshot" "full" "--no-clipboard" ];

        # ==========================================
        # Media keys
        # ==========================================
        "XF86AudioRaiseVolume".action.spawn = [ "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
        "XF86AudioLowerVolume".action.spawn = [ "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
        "XF86AudioMute".action.spawn = [ "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        "XF86AudioPlay".action.spawn = [ "${playerctl}" "play-pause" ];
        "XF86AudioPause".action.spawn = [ "${playerctl}" "play-pause" ];
        "XF86AudioNext".action.spawn = [ "${playerctl}" "next" ];
        "XF86AudioPrev".action.spawn = [ "${playerctl}" "previous" ];
        "XF86MonBrightnessDown".action.spawn = [ "${brightnessctl}" "set" "5%-" ];
        "XF86MonBrightnessUp".action.spawn = [ "${brightnessctl}" "set" "+5%" ];

        # ==========================================
        # Mouse binds
        # ==========================================
        "Mod+WheelScrollDown".action.focus-workspace-down = [];
        "Mod+WheelScrollUp".action.focus-workspace-up = [];
      };

      # Hotkey overlay (show available keybinds)
      hotkey-overlay = {
        skip-at-startup = true;
      };

      # Screenshot configuration
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

      # Animations (disabled for performance, like hyprland config)
      animations = {
        # Disable all animations
        workspace-switch.enable = false;
        window-open.enable = false;
        window-close.enable = false;
        horizontal-view-movement.enable = false;
        window-movement.enable = false;
        window-resize.enable = false;
        config-notification-open-close.enable = false;
        screenshot-ui-open.enable = false;
      };
    };

  # ydotool daemon (required for dictation text input)
  systemd.user.services.ydotoold = {
    Unit.Description = "ydotool daemon";
    Service.ExecStart = "${pkgs.ydotool}/bin/ydotoold";
    Install.WantedBy = [ "default.target" ];
  };

  # Required packages for niri keybinds
  home.packages = [
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.wireplumber  # For wpctl
  ];
}
