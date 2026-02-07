{ pkgs, ... }:

# System-level keyboard remapping with kanata
#
# Why kanata instead of keyd?
# - Supports mouse keys in layers (keyd is keyboard-only)
# - Same layer/overload concepts as keyd
# - Works everywhere: TTY, login screen, all WMs/DEs
#
# Key concepts (same as keyd, different syntax):
# - tap-hold: Hold activates action, tap sends key
#   Example: (tap-hold 200 200 esc lmet)
#     - Tap → escape
#     - Hold → meta/super key
#
# - one-shot: Press and release, next key gets modifier
#   Example: (one-shot 2000 lctl)
#     - Tap control, release, press 'c' → sends ctrl+c
#
# - layer-toggle: Hold to activate layer
#   Example: (tap-hold 200 200 scln (layer-toggle nav))
#     - Tap → semicolon
#     - Hold → navigation layer active
#
# - movemouse-*: Mouse pointer movement
#   Example: (movemouse-left 3 1) → move left, speed 3, accel 1

{
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [ ]; # Empty = all keyboards
        configFile = ./kanata.kbd;
      };
    };
  };
}
