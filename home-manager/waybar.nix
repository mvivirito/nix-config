{ pkgs, ... }:

{

  programs.waybar = {
    enable = true;
#    package = pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ]; });
    settings = {
      mainBar = {
        margin = "0";
        layer = "top";
        modules-left = ["hyprland/workspaces" "mpris" ];
        modules-center = [ "wlr/taskbar" ];
        modules-right = [ "network#interface" "network#speed" "cpu" "temperature" "backlight" "battery" "clock" "tray" ];

        persistent_workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
        };

        "hyprland/workspaces" = {
          on-click = "activate";
          sort-by-number = true;
        };

        mpris = {
          format = "{status_icon}<span weight='bold'>{artist}</span> | {title}";
          status-icons = {
            playing = "▶️  ";
            paused = "⏸️ ";
            stopped = "⏹️ ";
          };
        };

        "wlr/taskbar" = {
          on-click = "activate";
        };

        "network#interface" = {
          format-ethernet = "🖥️ {ifname}";
          format-wifi = "🌎 {ifname}";
          tooltip = true;
          tooltip-format = "{ipaddr}";
        };

        "network#speed" = {
          format = "⇡{bandwidthUpBits} ⇣{bandwidthDownBits}";
        };

        cpu = {
          format = "💻 {usage}% 📊{avg_frequency}";
        };

        temperature = {
          format = "{icon} {temperatureC} °C";
          format-icons = [ "🧊" "🏔️" "🧿" "🥵" ];
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "🌑" "🌓" "🌞 " ];
        };

        battery = {
          format-critical = "{icon} {capacity}%";
          format = "{icon} {capacity}%";
          format-icons = [ "🪫" "🔋" "🔋" "🔋" ];
        };

        clock = {
          format = "⌚ {:%H:%M}";
          format-alt = "🗓️ {:%Y-%m-%d}";
        };
      };
    };

    style = ''
      * {
        min-height: 0;
      }

      window#waybar {
        font-family: 'Noto', 'Noto Sans';
        font-size: 12px;
      }

      tooltip {
        background: @unfocused_borders;
      }

      #workspaces button {
        padding: 0px 4px;
        margin: 0 4px 0 0;
      }

      .modules-right * {
        padding: 0 4px;
        margin: 0 0 0 4px;
      }

      #mpris {
        padding: 0 4px;
      }

    '';
  };
}


