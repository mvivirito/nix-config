{ lib, pkgs, config, inputs, ... }:

{

  imports = [];

  # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
    ];
    bind =
      [
        "$mod SHIFT, N, exec, swaync-client -rs" 
        "$mod SHIFT, G, exec, grim - | wl-copy"
        "$mod, G, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, P, exec, wl-color-picker"
        "$mod SHIFT, Q, killactive"
        "$mod SHIFT, R, exec, thunar"
        "$mod SHIFT, X, exec, swaylock -i /home/michael/Pictures/lock_background.jpg -f" 
        "$mod, B, exec, firefox"
        "$mod, E, exec, rofimoji"
        "$mod, C, exec, rofi -show calc"
        "$mod, F, fullscreen"
        "$mod, M, exec, pkill Hyprland"
        "$mod, N, exec, swaync-client -op" 
        "$mod, P, pin"
        "$mod, R, exec, kitty -e ranger"
        "$mod, T, exec, hyprctl keyword general:layout 'master'"
        "$mod SHIFT, T, exec, hyprctl keyword general:layout 'dwindle'"
        "$mod, S, togglesplit"
        "$mod, V, togglefloating"
        "$mod, return, exec, kitty"
        "$mod, space, exec, tofi-drun --drun-launch=true"
        "$mod SHIFT, space, exec, tofi-run --drun-launch=true"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "ALT,Tab,cyclenext"
        "ALT,Tab,bringactivetotop"
        ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"
        ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +5%"

        # Application Launchers
        "$mod, D, exec, discord"
        "$mod, O, exec, 1password --quick-access"
        "$mod, Y, exec, kitty -e nvim"
        "$mod, I, exec, code"
        "$mod, Z, exec, vlc"

        # System Tools
        "$mod SHIFT, B, exec, pavucontrol"
        "$mod SHIFT, M, exec, gnome-system-monitor"
        "$mod SHIFT, Y, exec, kitty -e htop"

        # Enhanced Screenshots with notifications
        "$mod, Print, exec, grim - | wl-copy && notify-send 'Screenshot copied to clipboard'"
        "$mod SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy && notify-send 'Selection screenshot copied'"

        # Layout adjustments
        "$mod, U, exec, hyprctl keyword general:layout 'master'"

        # Display Management
        "$mod ALT, L, exec, bash ~/.config/waybar/scripts/display_layout.sh extend"
        "$mod ALT, M, exec, bash ~/.config/waybar/scripts/display_layout.sh mirror"
        "$mod ALT, E, exec, bash ~/.config/waybar/scripts/display_layout.sh external"
        "$mod ALT, K, exec, bash ~/.config/waybar/scripts/display_layout.sh laptop"

        # PDF Viewer - launches most recent PDF or prompts for selection
        "$mod SHIFT, D, exec, bash -c 'PDF=$(find ~/Documents ~/Downloads -name \"*.pdf\" -type f -printf \"%T@\\t%p\\n\" 2>/dev/null | sort -rn | head -1 | cut -f2); if [ -n \"$PDF\" ]; then xdg-open \"$PDF\"; else notify-send \"No PDF found\" \"Put PDFs in ~/Documents or ~/Downloads\"; fi'"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
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


      exec-once = [
        "swaync"
        "waybar"
        "[workspace 2 silent] firefox"
        "[workspace special:scratchpad silent] kitty --title='kitty-scratchpad'"
        "kitty"
        "[workspace 7 silent] kitty --title='kitty-journal'"
        "swaybg -i /home/michael/Pictures/background.jpg"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(5CBABA) rgb(7676FF) 45deg";
        "col.inactive_border" = "rgba(585272aa)";
        layout = "master";
        resize_on_border = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        orientation = "center";
      };

      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = true;
          noise = 0;
          brightness = 0.90;
        };
        inactive_opacity = 0.85;
        active_opacity = 1.0;
      };

      animations = {
        enabled = true;
        bezier = [
          "linear, 0, 0, 1, 1"
          "smooth, 0.4, 0, 0.2, 1"
        ];
        animation = [
          "windows, 1, 3, smooth, slide"
          "windowsOut, 1, 3, smooth, slide"
          "windowsMove, 1, 3, smooth, slide"
          "fade, 1, 3, smooth"
          "border, 1, 3, smooth"
          "borderangle, 1, 5, linear, loop"
          "workspaces, 1, 2, smooth"
        ];
      };

      group = {
        "col.border_active" = "rgba(63F2F1aa)";
        "col.border_inactive" = "rgba(585272aa)";

        groupbar = {
          font_family = "Iosevka";
          font_size = 13;
          "col.active" = "rgba(63F2F1aa)";
          "col.inactive" = "rgba(585272aa)";
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      input = {
        sensitivity = 0.15;
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          drag_lock = true;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_distance = 800;
        workspace_swipe_forever = true;
      };

      monitor = [
      # "eDP-1,preferred,auto,1.3"
      "DP-2,5120x1440@120.0,1661x0,1.0"
      "eDP-1,2160x1350@59.743999,6781x166,1.25"
      ];


  };
}
