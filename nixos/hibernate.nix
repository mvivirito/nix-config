{ config, pkgs, ... }:

# Automatic hibernation after suspend on battery power
#
# Problem: Laptops left suspended on battery will drain over days/weeks.
# Solution: Wake from suspend after timeout, check if still on battery, hibernate if so.
#
# How it works:
# 1. User suspends laptop (lid close or manual)
# 2. "awake-after-suspend-for-a-time" runs BEFORE suspend
#    - Checks if on battery power (AC offline)
#    - If yes: schedules RTC wake-up timer for 930 seconds (15.5 min)
#    - Writes timestamp to lock file for verification
#    - If on AC: does nothing (skip hibernation on desktop docking)
# 3. System suspends normally
# 4. RTC wakes system after 930 seconds
# 5. "hibernate-after-recovery" runs AFTER resume
#    - Reads timestamp from lock file
#    - Calculates elapsed time since suspend
#    - If >= 930 seconds (timeout reached): hibernates
#    - If < 930 seconds (user woke manually): cancels, sets 1-second dummy timer
#
# Trade-offs:
# - 930 seconds (15.5 min) balances power saving vs. responsiveness
# - Brief wake-up every 15 min wastes some power, but less than staying suspended for days
# - Lock file in /var/run persists across suspend but not reboot (correct)
#
# Security: Requires swaylock integration - suspend triggers lock, hibernate preserves lock
#
# Coordination with swayidle (home-manager/home.nix):
# - Same 930-second timeout ensures lock → DPMS → hibernate sequence

let
  hibernateEnvironment = {
    HIBERNATE_SECONDS = "930";                      # 15.5 minutes
    HIBERNATE_LOCK = "/var/run/autohibernate.lock";
  };
in {

  # Service 1: Schedule wake-up before suspend
  systemd.services."awake-after-suspend-for-a-time" = {
    description = "Sets up the suspend so that it'll wake for hibernation only if not on AC power";
    wantedBy = [ "suspend.target" ];
    before = [ "systemd-suspend.service" ];  # Runs BEFORE actual suspend
    environment = hibernateEnvironment;
    script = ''
      # Only schedule wake-up if on battery (AC offline = 0)
      if [ $(cat /sys/class/power_supply/AC/online) -eq 0 ]; then
        curtime=$(date +%s)
        echo "$curtime $1" >> /tmp/autohibernate.log
        echo "$curtime" > $HIBERNATE_LOCK         # Record suspend time
        ${pkgs.util-linux}/bin/rtcwake -m no -s $HIBERNATE_SECONDS  # Schedule RTC wake (-m no = don't suspend, just set timer)
      else
        echo "System is on AC power, skipping wake-up scheduling for hibernation." >> /tmp/autohibernate.log
      fi
    '';
    serviceConfig.Type = "simple";
  };

  # Service 2: Hibernate after timeout-induced resume
  systemd.services."hibernate-after-recovery" = {
    description = "Hibernates after a suspend recovery due to timeout";
    wantedBy = [ "suspend.target" ];
    after = [ "systemd-suspend.service" ];   # Runs AFTER resume
    environment = hibernateEnvironment;
    script = ''
      curtime=$(date +%s)
      sustime=$(cat $HIBERNATE_LOCK)         # Read suspend timestamp
      rm $HIBERNATE_LOCK                      # Clean up lock file

      # If timeout elapsed (>= 930 sec), this was RTC wake → hibernate
      if [ $(($curtime - $sustime)) -ge $HIBERNATE_SECONDS ] ; then
        systemctl hibernate
      else
        # User woke manually before timeout → cancel hibernation
        # Set 1-second dummy timer to clear RTC wake alarm
        ${pkgs.util-linux}/bin/rtcwake -m no -s 1
      fi
    '';
    serviceConfig.Type = "simple";
  };

}
