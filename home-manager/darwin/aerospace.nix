# Aerospace tiling window manager configuration for macOS
# Keybindings use Ctrl+Alt (triggered by Caps Lock or Right Command via Karabiner)
#
# Template-based config: generates laptop.toml and ultrawide.toml profiles.
# Hammerspoon hot-swaps ~/.aerospace.toml based on connected monitors.
{ config, lib, pkgs, ... }:
let
  # Generate a full aerospace TOML config string with parameterized gaps
  makeAerospaceConfig = { outerLeft, outerRight, outerTop, outerBottom, innerH, innerV }:
    ''
      # Tiling defaults
      default-root-container-layout = "tiles"
      default-root-container-orientation = "auto"
      start-at-login = false  # managed by launchd instead
      automatically-unhide-macos-hidden-apps = true

      [gaps]
      [gaps.outer]
      left = ${toString outerLeft}
      bottom = ${toString outerBottom}
      top = ${toString outerTop}
      right = ${toString outerRight}

      [gaps.inner]
      horizontal = ${toString innerH}
      vertical = ${toString innerV}

      # Focus (Ctrl+Alt + hjkl) - triggered by Caps/RCmd + hjkl
      [mode.main.binding]
      ctrl-alt-h = "focus left"
      ctrl-alt-j = "focus down"
      ctrl-alt-k = "focus up"
      ctrl-alt-l = "focus right"

      # Move windows (Ctrl+Alt+Shift + hjkl)
      ctrl-alt-shift-h = "move left"
      ctrl-alt-shift-j = "move down"
      ctrl-alt-shift-k = "move up"
      ctrl-alt-shift-l = "move right"

      # Workspaces (ctrl-alt)
      ctrl-alt-1 = "workspace 1"
      ctrl-alt-2 = "workspace 2"
      ctrl-alt-3 = "workspace 3"
      ctrl-alt-4 = "workspace 4"
      ctrl-alt-5 = "workspace 5"
      ctrl-alt-6 = "workspace 6"
      ctrl-alt-7 = "workspace 7"
      ctrl-alt-8 = "workspace 8"
      ctrl-alt-9 = "workspace 9"

      # Workspaces (cmd)
      cmd-1 = "workspace 1"
      cmd-2 = "workspace 2"
      cmd-3 = "workspace 3"
      cmd-4 = "workspace 4"
      cmd-5 = "workspace 5"
      cmd-6 = "workspace 6"
      cmd-7 = "workspace 7"
      cmd-8 = "workspace 8"
      cmd-9 = "workspace 9"

      # Move to workspace (ctrl-alt-shift)
      ctrl-alt-shift-1 = "move-node-to-workspace 1"
      ctrl-alt-shift-2 = "move-node-to-workspace 2"
      ctrl-alt-shift-3 = "move-node-to-workspace 3"
      ctrl-alt-shift-4 = "move-node-to-workspace 4"
      ctrl-alt-shift-5 = "move-node-to-workspace 5"
      ctrl-alt-shift-6 = "move-node-to-workspace 6"
      ctrl-alt-shift-7 = "move-node-to-workspace 7"
      ctrl-alt-shift-8 = "move-node-to-workspace 8"
      ctrl-alt-shift-9 = "move-node-to-workspace 9"

      # Move to workspace (cmd-shift)
      cmd-shift-1 = "move-node-to-workspace 1"
      cmd-shift-2 = "move-node-to-workspace 2"
      cmd-shift-3 = "move-node-to-workspace 3"
      cmd-shift-4 = "move-node-to-workspace 4"
      cmd-shift-5 = "move-node-to-workspace 5"
      cmd-shift-6 = "move-node-to-workspace 6"
      cmd-shift-7 = "move-node-to-workspace 7"
      cmd-shift-8 = "move-node-to-workspace 8"
      cmd-shift-9 = "move-node-to-workspace 9"

      # Window operations
      ctrl-alt-f = "fullscreen"
      ctrl-alt-t = "layout floating tiling"
      ctrl-alt-backslash = "layout tiles accordion"
      ctrl-alt-equal = "layout h_tiles v_tiles h_accordion v_accordion"
      ctrl-alt-shift-q = "exec-and-forget osascript -e 'tell application \"System Events\" to keystroke \"q\" using command down'"
      ctrl-alt-r = "mode resize"
      ctrl-alt-shift-t = "mode service"

      # App launchers
      ctrl-alt-enter = "exec-and-forget open -na 'Alacritty'"
      ctrl-alt-b = "exec-and-forget open -na 'Google Chrome'"
      ctrl-alt-o = "exec-and-forget open -a '1Password'"
      ctrl-alt-y = "exec-and-forget /Applications/Alacritty.app/Contents/MacOS/alacritty -e /bin/zsh -lc nvim"

      # Toggle aerospace on/off
      ctrl-alt-shift-e = "enable toggle"

      [mode.resize.binding]
      h = "resize width -50"
      j = "resize height +50"
      k = "resize height -50"
      l = "resize width +50"
      esc = "mode main"
      enter = "mode main"

      [mode.service.binding]
      ctrl-alt-shift-t = "mode main"
      r = ["flatten-workspace-tree", "mode main"]
      f = ["layout floating tiling", "mode main"]

      # Floating rules
      [[on-window-detected]]
      if.app-id = "com.apple.PhotoBooth"
      run = "layout floating"

      [[on-window-detected]]
      if.app-id = "com.apple.systempreferences"
      run = "layout floating"
    '';

  laptopConfig = makeAerospaceConfig {
    outerLeft = 8;
    outerRight = 8;
    outerTop = 8;
    outerBottom = 8;
    innerH = 8;
    innerV = 8;
  };

  ultrawideConfig = makeAerospaceConfig {
    outerLeft = 300;
    outerRight = 300;
    outerTop = 8;
    outerBottom = 8;
    innerH = 8;
    innerV = 8;
  };
in
{
  # Install aerospace package
  home.packages = [ pkgs.aerospace ];

  # Place template configs as immutable reference files
  home.file.".config/aerospace/laptop.toml".text = laptopConfig;
  home.file.".config/aerospace/ultrawide.toml".text = ultrawideConfig;

  # Copy laptop config to ~/.aerospace.toml if it doesn't already exist
  # (preserves Hammerspoon's last switch across rebuilds)
  home.activation.aerospaceConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.aerospace.toml" ] && [ -f "$HOME/.config/aerospace/laptop.toml" ]; then
      cp "$HOME/.config/aerospace/laptop.toml" "$HOME/.aerospace.toml"
    fi
  '';

  # Start aerospace at login via launchd
  launchd.agents.aerospace = {
    enable = true;
    config = {
      Label = "com.user.aerospace";
      ProgramArguments = [ "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace" ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
