{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    env = [
      "XCURSOR_SIZE,32"
      "HYPRCURSOR_SIZE,32"
    ];

    # Border colors (minimal monochrome theme)
    "$borderActive" = "0xff4a4a4a";      # Monochrome active
    "$borderInactive" = "0xff2f2f2f";    # Monochrome inactive

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 1;
      "col.active_border" = "$borderActive";
      "col.inactive_border" = "$borderInactive";
      layout = "master";  # Default layout (toggle to dwindle with MOD+TAB)
      resize_on_border = true;
    };

    # Dwindle layout (spiral/Fibonacci tiling)
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    # Master layout (optimized for ultrawide)
    master = {
      orientation = "left";  # Master window on left side
    };

    decoration = {
      rounding = 6;
      blur = {
        enabled = false;
        size = 8;
        passes = 2;
        new_optimizations = true;
        ignore_opacity = true;
        noise = 0;
        brightness = 0.90;
      };
      inactive_opacity = 1.0;
      active_opacity = 1.0;
    };

    animations = {
      enabled = false;  # Disabled for performance
    };

    group = {
      "col.border_active" = "$borderActive";
      "col.border_inactive" = "$borderInactive";

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
      background_color = "0x0d1117"; # Sleek GitHub-dark style color
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

    # Touchpad gestures
    gestures = {
      gesture = [
        "3, horizontal, workspace"  # Three-finger swipe to switch workspace
      ];
      workspace_swipe_distance = 800;
      workspace_swipe_forever = true;
    };
  };
}
