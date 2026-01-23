{ pkgs, lib, ... }:

# System-level keyboard remapping with keyd
#
# Why keyd instead of Hyprland keybinds?
# - Works everywhere: TTY, login screen, all WMs/DEs
# - Low-level remapping happens before any window manager sees keys
# - Required for capslock→escape+super (needs both tap and hold behavior)
#
# Key concepts:
# - overload(layer, tap): Hold activates layer, tap sends key
#   Example: capslock = overload(meta, esc)
#     - Tap capslock → escape
#     - Hold capslock → meta/super key
#     - Hold capslock + h/j/k/l → arrow keys (via nav layer)
#
# - oneshot(modifier): Press and release, next key gets modifier
#   Example: control = oneshot(control)
#     - Tap control, release, press 'c' → sends ctrl+c
#     - No need to hold control down
#     - Great for Emacs-style chording without RSI
#
# - Layer syntax: [layername] defines key mappings active when layer held
#
# Why this configuration?
# - capslock→escape: Vim muscle memory (ubiquitous among Vim users)
# - capslock→super: Tiling WM keybinds without moving hands
# - oneshot modifiers: Reduce RSI from holding modifiers
# - semicolon overload: Vim navigation (;+hjkl) without leaving home row
# - rightalt→meta: Another super key option (personal preference)

{
  environment.systemPackages = with pkgs; [ keyd ];

  services.keyd = {
   enable = true;
   };

  # Load keyd configuration from ./keyd.conf
  environment.etc."keyd/default.conf".source = ./keyd.conf;

  # Quirk to make keyd virtual keyboard recognized as internal
  # Without this, some tools treat keyd output as external keyboard
  # Vendor ID 0xFAC is keyd's virtual device identifier
  environment.etc."libinput/local-overrides.quirks".text = ''
    [keyd virtual keyboard]
    MatchUdevType=keyboard
    MatchVendor=0xFAC
    AttrKeyboardIntegration=internal
  '';
}
