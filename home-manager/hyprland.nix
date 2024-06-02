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
        "$mod, B, exec, firefox"
        "$mod, F, fullscreen"
	"$mod, return, exec, kitty"
	"$mod SHIFT, Q, killactive"
	"$mod, M, exec, pkill Hyprland"
	"$mod, R, exec, kitty -e ranger"
	"$mod SHIFT, R, exec, thunar"
	"$mod, E, exec, rofimoji"
	"$mod SHIFT, X, exec, swaylock -i /home/michael/Pictures/lock_background.jpg -f" 
	"$mod SHIFT, N, exec, swaync-client -rs" 
	"$mod, N, exec, swaync-client -op" 
	"$mod, V, togglefloating"
	"$mod, space, exec, rofi -show drun"
	"$mod, P, exec, wl-color-picker"
	"$mod, J, togglesplit"
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
       #  "[workspace special:term silent] kitty --title='kitty-scratch' --hold"
        "kitty"
       #  "remind -z -k':notify-send -u critical \"Reminder!\" %s' ~/00-09-System/02-Logs/02.10-Journal/agenda.rem"
       #  "[workspace 7 silent] morgen"
        "[workspace 7 silent] kitty --title='kitty-journal'"
        "swaybg -i /home/michael/Pictures/background.jpg"
      ];

#      workspace = lib.lists.flatten (map
#        (m:
#          map (w: "${w}, monitor:${m.name}") (m.workspaces)
#        )
#        (config.monitors));

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
        orientation = "left";
      };

      decoration = {
        rounding = 15;
        blur = {
          enabled = true;
          size = 10;
          passes = 3;
          new_optimizations = true;
	  ignore_opacity = true;
          noise = 0;
          brightness = 0.90;
        };
        inactive_opacity = 0.80;
        active_opacity = 0.90;
        drop_shadow = true;
        shadow_range = 7;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
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
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
      };

      monitor = [
      "eDP-1,preferred,auto,1.3"
      ];
  };
}


# Example special workspace (scratchpad)
#bind = $mainMod, S, togglespecialworkspace, magic
#bind = $mainMod SHIFT, S, movetoworkspace, special:magic

