
{ pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      [
        "$mod, F, exec, firefox"
	"$mod, Q, exec, kitty"
	"$mod, C, killactive"
	"$mod, M, exit"
	#$mod, E, exec, dolphin
	#$mod, V, togglefloating, 
	#$mod, R, exec, wofi --show drun
	#$mod, P, pseudo, # dwindle
	#$mod, J, togglesplit, # dwindle
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
      #  "hyprctl setcursor Bibata-Modern-Ice 22"
      #  "nm-applet"
      #  "swaybg -i ~/wallpaper -m fill"
        "waybar"
      #  "[workspace 2 silent] floorp"
      #  "[workspace special:term silent] kitty --title='kitty-scratch' --hold"
        "kitty"
        # "remind -z -k':notify-send -u critical \"Reminder!\" %s' ~/00-09-System/02-Logs/02.10-Journal/agenda.rem"
      #  "[workspace 7 silent] morgen"
        "[workspace 7 silent] kitty --title='kitty-journal'"
      ];

      workspace = lib.lists.flatten (map
        (m:
          map (w: "${w}, monitor:${m.name}") (m.workspaces)
        )
        (config.monitors));

      env = [ "XCURSOR_SIZE,24" ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgb(78A8FF) rgb(7676FF) 45deg";
        "col.inactive_border" = "rgba(585272aa)";
        layout = "dwindle";
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
        rounding = 0;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
        };
        drop_shadow = true;
        shadow_range = 4;
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

  };
}



#monitor=,preferred,auto,auto

#env = XCURSOR_SIZE,24

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
#input {
#    kb_layout = us
#    kb_variant =
#    kb_model =
#    kb_options =
#    kb_rules =

#    follow_mouse = 1

#    touchpad {
#        natural_scroll = no
#    }
#
#    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
#}


#general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

#    gaps_in = 5
#    gaps_out = 20
#    border_size = 2
#    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
#    col.inactive_border = rgba(595959aa)

#    layout = dwindle

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
#    allow_tearing = false
#}

#decoration {
#    # See https://wiki.hyprland.org/Configuring/Variables/ for more
#
#    rounding = 10
#    
#    blur {
#        enabled = true
#        size = 3
#        passes = 1
#    }

#    drop_shadow = yes
#    shadow_range = 4
#    shadow_render_power = 3
#    col.shadow = rgba(1a1a1aee)
#}

#animations {
#    enabled = yes

    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

#    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
#
#    animation = windows, 1, 7, myBezier
#    animation = windowsOut, 1, 7, default, popin 80%
#    animation = border, 1, 10, default
#    animation = borderangle, 1, 8, default
#    animation = fade, 1, 7, default
#    animation = workspaces, 1, 6, default
#}

#dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
#    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
#    preserve_split = yes # you probably want this
#}

#master {
#    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
#    new_is_master = true
#}

#gestures {
#    # See https://wiki.hyprland.org/Configuring/Variables/ for more
#    workspace_swipe = off
#}

#misc {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
#    force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
#}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
#device:epic-mouse-v1 {
#    sensitivity = -0.5
#}


# See https://wiki.hyprland.org/Configuring/Keywords/ for more
#$mainMod = SUPER

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
#bind = $mainMod, Q, exec, kitty
#bind = $mainMod, C, killactive, 
#bind = $mainMod, M, exit, 
#bind = $mainMod, E, exec, dolphin
#bind = $mainMod, V, togglefloating, 
#bind = $mainMod, R, exec, wofi --show drun
#bind = $mainMod, P, pseudo, # dwindle
#bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
#bind = $mainMod, left, movefocus, l
#bind = $mainMod, right, movefocus, r
#bind = $mainMod, up, movefocus, u
#bind = $mainMod, down, movefocus, d

# Example special workspace (scratchpad)
#bind = $mainMod, S, togglespecialworkspace, magic
#bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
#bind = $mainMod, mouse_down, workspace, e+1
#bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
#bindm = $mainMod, mouse:272, movewindow
#bindm = $mainMod, mouse:273, resizewindow
