{
  pkgs,
  inputs,
  ...
}: let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # tuigreet: TUI (text user interface) login greeter
        # Why tuigreet instead of GDM/SDDM?
        # - Aesthetic: minimal, fast, no GUI overhead
        # - Works on TTY1 without X11/Wayland running
        # - Remembers last user and session (convenience)
        #
        # Flags:
        # --time: shows clock
        # --remember: remembers last username
        # --remember-session: remembers last session (Hyprland)
        # --sessions: available sessions from /usr/share/wayland-sessions/
        command = "${tuigreet} --time --remember --remember-session --sessions Hyprland";
        user = "greeter";  # Runs as unprivileged 'greeter' user (security)
      };
    };
  };

  # CRITICAL systemd service configuration
  # Without these settings, greetd is unusable (bootlogs spam screen, errors everywhere)
  #
  # Why this is undocumented everywhere:
  # - Most greetd examples use graphical greeters (wlgreet, agreety)
  # - tuigreet on TTY has special requirements
  # - This config found via Reddit after hours of debugging
  #
  # What each setting does:
  # - Type = "idle": Don't fork, run as simple foreground process
  # - StandardInput = "tty": Read keyboard input from TTY
  # - StandardOutput = "tty": Write output to TTY (not journal)
  # - StandardError = "journal": Send ERRORS to journal (not screen)
  #   → Critical: without this, errors spam on screen over login prompt
  # - TTYReset = true: Reset TTY state before starting
  #   → Clears any leftover text from boot
  # - TTYVHangup = true: Hang up TTY before starting
  #   → Closes any previous session on this TTY
  # - TTYVTDisallocate = true: Deallocate VT after service stops
  #   → Prevents TTY from staying allocated after logout
  #
  # Result: Clean login screen, no boot spam, proper TTY handling
  #
  # Reference: https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
