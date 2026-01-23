{ pkgs, config, ... }:

let
  # Package paths for keybind commands
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  tofi = "${pkgs.tofi}/bin/tofi";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  wlPaste = "${pkgs.wl-clipboard}/bin/wl-paste";
  wlClipPersist = "${pkgs.wl-clip-persist}/bin/wl-clip-persist";
in {
  # Install clipboard picker script
  home.file.".config/hyprland/scripts/clipboard-picker.sh" = {
    source = ./scripts/clipboard-picker.sh;
    executable = true;
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # Exec-once: Run at Hyprland startup
    exec-once = [
      "swaync"                                              # Notification daemon
      "${wlClipPersist} --clipboard --primary"              # Persist clipboard after app closes
      "${wlPaste} --type text --watch ${cliphist} store"    # Store text in clipboard history
      "${wlPaste} --type image --watch ${cliphist} store"   # Store images in clipboard history
      "waybar"                                              # Status bar
      "[workspace 2 silent] firefox"                        # Start Firefox on workspace 2
      "[workspace special:scratchpad silent] kitty --title='kitty-scratchpad'"  # Scratchpad terminal
      "kitty"                                               # Main terminal on workspace 1
      "[workspace 7 silent] kitty --title='kitty-journal'" # Journal terminal
    ];

    # Mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # Keyboard binds
    bind = [
      # Window management
      "$mod SHIFT, Q, killactive"
      "$mod, F, fullscreen"
      "$mod, P, pin"
      "$mod, V, togglefloating"

      # Layout controls
      "$mod, M, layoutmsg, swapwithmaster master"
      "$mod, TAB, exec, bash -c 'current=$(hyprctl getoption general:layout | grep \"str:\" | awk \"{print \\$2}\"); if [ \"$current\" = \"master\" ]; then hyprctl keyword general:layout dwindle; else hyprctl keyword general:layout master; fi'"
      "$mod, S, togglesplit"
      "$mod CTRL, J, swapnext"
      "$mod CTRL, K, swapnext, prev"

      # Focus movement (vim keys + arrows)
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Window movement (vim keys + arrows)
      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, L, movewindow, r"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, J, movewindow, d"
      "$mod SHIFT, left, movewindow, l"
      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, up, movewindow, u"
      "$mod SHIFT, down, movewindow, d"

      # Alt-Tab cycling
      "ALT,Tab,cyclenext"
      "ALT,Tab,bringactivetotop"

      # Application launchers
      "$mod, return, exec, kitty"
      "$mod, space, exec, tofi-drun --drun-launch=true"
      "$mod SHIFT, space, exec, bash -c 'cmd=$(tofi-run); [ -z \"$cmd\" ] && exit 0; exec ${pkgs.kitty}/bin/kitty -e bash -lc \"$cmd\"'"
      "$mod, B, exec, firefox"
      "$mod, D, exec, discord"
      "$mod, O, exec, 1password --quick-access"
      "$mod, Y, exec, kitty -e nvim"
      "$mod, I, exec, code"
      "$mod, Z, exec, vlc"
      "$mod, R, exec, kitty -e ranger"

      # System tools
      "$mod SHIFT, B, exec, pavucontrol"
      "$mod SHIFT, M, exec, gnome-system-monitor"
      "$mod SHIFT, Y, exec, kitty -e htop"
      "$mod SHIFT, R, exec, thunar"
      "$mod SHIFT, X, exec, swaylock -i /home/michael/Pictures/lock_background.jpg -f"
      "$mod SHIFT, E, exec, pkill Hyprland"

      # Screenshots
      # Note: pkill -x slurp cleans up any hung slurp processes before taking new screenshot
      "$mod, G, exec, bash -c 'pkill -x slurp >/dev/null 2>&1; grim -g \"$(slurp)\" - | wl-copy; notify-send \"Selection copied\"'"
      "$mod SHIFT, G, exec, bash -c 'pkill -x slurp >/dev/null 2>&1; grim - | wl-copy; notify-send \"Screenshot copied\"'"
      "$mod, Print, exec, bash -c 'dir=\"$HOME/Pictures/Screenshots\"; mkdir -p \"$dir\"; file=\"$dir/$(date +%Y-%m-%d_%H-%M-%S).png\"; pkill -x slurp >/dev/null 2>&1; grim -g \"$(slurp)\" \"$file\"; notify-send \"Selection saved\" \"$file\"'"
      "$mod SHIFT, Print, exec, bash -c 'dir=\"$HOME/Pictures/Screenshots\"; mkdir -p \"$dir\"; file=\"$dir/$(date +%Y-%m-%d_%H-%M-%S).png\"; pkill -x slurp >/dev/null 2>&1; grim \"$file\"; notify-send \"Screenshot saved\" \"$file\"'"

      # Clipboard & utilities
      "$mod SHIFT, V, exec, ~/.config/hyprland/scripts/clipboard-picker.sh"
      "$mod SHIFT, P, exec, wl-color-picker"
      "$mod, E, exec, rofimoji"
      "$mod, C, exec, rofi -show calc"

      # Notifications
      "$mod, N, exec, swaync-client -op"
      "$mod SHIFT, N, exec, swaync-client -rs"

      # Display management
      "$mod ALT, L, exec, bash ~/.config/waybar/scripts/display_layout.sh extend"
      "$mod ALT, M, exec, bash ~/.config/waybar/scripts/display_layout.sh mirror"
      "$mod ALT, E, exec, bash ~/.config/waybar/scripts/display_layout.sh external"
      "$mod ALT, K, exec, bash ~/.config/waybar/scripts/display_layout.sh laptop"

      # PDF viewer (most recent PDF)
      "$mod SHIFT, D, exec, bash -c 'PDF=$(find ~/Documents ~/Downloads -name \"*.pdf\" -type f -printf \"%T@\\t%p\\n\" 2>/dev/null | sort -rn | head -1 | cut -f2); if [ -n \"$PDF\" ]; then zathura \"$PDF\"; else notify-send \"No PDF found\" \"Put PDFs in ~/Documents or ~/Downloads\"; fi'"

      # Media keys
      ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPause, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
      ",XF86MonBrightnessUp,exec,brightnessctl set +5%"
    ]
    ++ (
      # Generate workspace binds: MOD+1-0 switches to WS1-10, MOD+SHIFT+1-0 moves windows
      # Uses builtins.genList to avoid 20 lines of repetitive binds
      #
      # Math explanation:
      # - ws = toString (x + 1 - (c * 10))
      # - c = (x + 1) / 10 (integer division)
      # - x=0: c=1/10=0, ws=1-0=1 → workspace 1
      # - x=8: c=9/10=0, ws=9-0=9 → workspace 9
      # - x=9: c=10/10=1, ws=10-10=0 → workspace 10 (key "0")
      #
      # Result: MOD+1 → WS1, MOD+2 → WS2, ..., MOD+0 → WS10
      builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        )
        10)
    );
  };
}
