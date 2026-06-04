{ pkgs, ... }:

# Suspend / hibernate behavior.
#
# Lid close on BATTERY   -> suspend-then-hibernate (set in shared/power.nix):
#   systemd suspends immediately, then hibernates after HibernateDelaySec below
#   if still asleep. This is systemd's tested native path.
# Lid close on AC/docked -> plain suspend (see shared/power.nix).
#
# This REPLACES a previous hand-rolled scheme (suspend -> rtcwake RTC alarm ->
# `systemctl hibernate` from a resume hook). That scheme woke the whole OS with
# the lid shut to decide whether to hibernate; if the hibernate step hung
# (intermittent on this Tiger Lake / i915 hardware) the machine sat awake and
# overheated in a closed clamshell. Native suspend-then-hibernate is more robust
# and integrates with the lock screen.
#
# CAVEAT (rolling release): a hibernation image can only be resumed by the SAME
# kernel that wrote it. After `nixos-rebuild switch` bumps the kernel, the
# systemd-boot default points at the NEW kernel, so resuming an image written by
# the still-running OLD kernel fails -> cold boot -> lost session. The
# reboot-needed-notify user service below warns you to reboot after such a switch.

{
  # How long to stay suspended before hibernating (battery / suspend-then-hibernate).
  # Longer delay = fewer hibernate attempts = less exposure to the driver-level
  # hibernate hang; 30 min on a suspended laptop costs very little battery.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };

  # Warn (desktop notification) when the running kernel != the activated kernel,
  # i.e. a rebuild changed the kernel but you have not rebooted yet. In that state
  # hibernate would NOT resume, so this is the cue to reboot.
  systemd.user.services.reboot-needed-notify = {
    description = "Notify when a reboot is needed (kernel changed; hibernate won't resume)";
    serviceConfig.Type = "oneshot";
    script = ''
      booted=$(readlink /run/booted-system/kernel 2>/dev/null || true)
      current=$(readlink /run/current-system/kernel 2>/dev/null || true)
      if [ -n "$booted" ] && [ -n "$current" ] && [ "$booted" != "$current" ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical \
          "Reboot needed" \
          "The system kernel changed since boot. Hibernate will NOT resume until you reboot — an unsaved session would be lost. Run: sudo reboot"
      fi
    '';
  };

  systemd.user.timers.reboot-needed-notify = {
    description = "Periodically check whether a reboot is needed for hibernate safety";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "2min";
      OnUnitActiveSec = "15min";
      Unit = "reboot-needed-notify.service";
    };
  };
}
