# Aerospace tiling window manager configuration for macOS
# Keybindings use Ctrl+Alt (triggered by Caps Lock or Right Command via Karabiner)
{ config, lib, pkgs, ... }: {
  programs.aerospace = {
    enable = true;

    settings = {
      gaps = {
        outer = { left = 8; bottom = 8; top = 8; right = 8; };
        inner = { horizontal = 8; vertical = 8; };
      };

      mode.main.binding = {
        # Focus (Ctrl+Alt + hjkl) - triggered by Caps/RCmd + hjkl
        "ctrl-alt-h" = "focus left";
        "ctrl-alt-j" = "focus down";
        "ctrl-alt-k" = "focus up";
        "ctrl-alt-l" = "focus right";

        # Move windows (Ctrl+Alt+Shift + hjkl)
        "ctrl-alt-shift-h" = "move left";
        "ctrl-alt-shift-j" = "move down";
        "ctrl-alt-shift-k" = "move up";
        "ctrl-alt-shift-l" = "move right";

        # Workspaces
        "ctrl-alt-1" = "workspace 1";
        "ctrl-alt-2" = "workspace 2";
        "ctrl-alt-3" = "workspace 3";
        "ctrl-alt-4" = "workspace 4";
        "ctrl-alt-5" = "workspace 5";
        "ctrl-alt-6" = "workspace 6";
        "ctrl-alt-7" = "workspace 7";
        "ctrl-alt-8" = "workspace 8";
        "ctrl-alt-9" = "workspace 9";

        # Move to workspace
        "ctrl-alt-shift-1" = "move-node-to-workspace 1";
        "ctrl-alt-shift-2" = "move-node-to-workspace 2";
        "ctrl-alt-shift-3" = "move-node-to-workspace 3";
        "ctrl-alt-shift-4" = "move-node-to-workspace 4";
        "ctrl-alt-shift-5" = "move-node-to-workspace 5";
        "ctrl-alt-shift-6" = "move-node-to-workspace 6";
        "ctrl-alt-shift-7" = "move-node-to-workspace 7";
        "ctrl-alt-shift-8" = "move-node-to-workspace 8";
        "ctrl-alt-shift-9" = "move-node-to-workspace 9";

        # Window operations
        "ctrl-alt-f" = "fullscreen";
        "ctrl-alt-space" = "layout floating tiling";
        "ctrl-alt-backslash" = "layout tiles accordion";
        "ctrl-alt-equal" = "layout h_tiles v_tiles h_accordion v_accordion";
        "ctrl-alt-shift-q" = "close";
        "ctrl-alt-r" = "mode resize";
        "ctrl-alt-shift-t" = "mode service";

        # App launchers (use -n for new instance, or just focus if already open)
        "ctrl-alt-enter" = "exec-and-forget open -na 'Ghostty'";
        "ctrl-alt-b" = "exec-and-forget open -na 'Google Chrome'";
        "ctrl-alt-o" = "exec-and-forget open -a '1Password'";  # 1Password should just focus
        "ctrl-alt-y" = "exec-and-forget /Applications/Ghostty.app/Contents/MacOS/ghostty -e /bin/zsh -lc nvim";
      };

      mode.resize.binding = {
        "h" = "resize width -50";
        "j" = "resize height +50";
        "k" = "resize height -50";
        "l" = "resize width +50";
        "esc" = "mode main";
        "enter" = "mode main";
      };

      mode.service.binding = {
        "ctrl-alt-shift-t" = "mode main";
        "r" = ["flatten-workspace-tree" "mode main"];
        "f" = ["layout floating tiling" "mode main"];
      };
    };
  };
}
