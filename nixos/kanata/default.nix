{ pkgs, lib, ... }:

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
#
# Push-to-talk for handy:
# - PgDn sends SIGUSR2 to the running handy instance on press AND release.
#   Hold-to-talk feel; release stops recording. Requires kanata-with-cmd
#   and `danger-enable-cmd yes`. The unit runs as user `michael` so the
#   signal can reach the user-owned handy process.
# - We send signals rather than calling `handy --toggle-transcription`
#   because the CLI always boots the GUI app (Tauri/tao event loop), which
#   panics without a Wayland display in the kanata service's context.

{
  services.kanata = {
    enable = true;
    package = pkgs.kanata-with-cmd;
    keyboards.default = {
      devices = [ ];
      extraDefCfg = ''
        process-unmapped-keys yes
        danger-enable-cmd yes
      '';
      config = ''
        (defsrc
          caps lctl lsft ralt scln apos
          a    s    d    e    f    g
          h    j    k    l    u    i
          pgdn
        )

        (defvirtualkeys
          handy-toggle (cmd ${pkgs.procps}/bin/pkill -USR2 -n handy)
        )

        (defalias
          ;; Capslock: tap for escape, hold for super/meta
          caps (tap-hold 200 200 esc lmet)

          ;; Oneshot modifiers: tap-release-press instead of hold
          ;; Reduces RSI from holding modifiers
          ctl (one-shot 2000 lctl)
          sft (one-shot 2000 lsft)

          ;; Right alt: tap for escape, hold for super (same as caps)
          ralt (tap-hold 200 200 esc lmet)

          ;; Semicolon: tap for semicolon, hold for nav layer
          nav (tap-hold 200 200 scln (layer-toggle navigation))

          ;; Apostrophe: tap for apostrophe, hold for control
          apo (tap-hold 200 200 apos lctl)

          ;; Mouse movement aliases (speed=3, acceleration=1)
          ml (movemouse-left 3 1)
          md (movemouse-down 3 1)
          mu (movemouse-up 3 1)
          mr (movemouse-right 3 1)

          ;; Push-to-talk: toggle handy on press, toggle off on release
          ptt (multi
                (on-press tap-vkey handy-toggle)
                (on-release tap-vkey handy-toggle))
        )

        (deflayer base
          @caps @ctl @sft @ralt @nav  @apo
          a     s    d    e     f     g
          h     j    k    l     u     i
          @ptt
        )

        (deflayer navigation
          _     _    _    _     _     _
          mlft  @ml  @md  @mu   @mr   mrgt
          left  down up   rght  S-grv S-\
          _
        )
      '';
    };
  };

  # Run kanata as user michael (not DynamicUser) so the `cmd` action can
  # send signals to handy in the user session. ProtectProc must be relaxed
  # so pkill can enumerate /proc to find handy's PID.
  systemd.services.kanata-default.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "michael";
    Group = "users";
    ProtectHome = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectProc = lib.mkForce "default";
  };
}
