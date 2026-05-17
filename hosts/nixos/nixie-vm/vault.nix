# Vault (second/third brain) services and packages
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git-lfs
    rclone
    obsidian
  ];

  services.syncthing = {
    enable = true;
    user = "michael";
    group = "users";
    dataDir = "/home/michael";
    configDir = "/home/michael/.config/syncthing";
    openDefaultPorts = true;      # TCP 22000, UDP 21027
    overrideDevices = false;       # allow GUI device pairing
    overrideFolders = false;       # allow GUI folder pairing
  };

  # Open Syncthing GUI port for localhost-only access
  networking.firewall.allowedTCPPorts = [ 8384 ];

  # User systemd timers for vault automation
  # Note: services.* would be system-scope; using systemd.user.* for per-user
  systemd.user.services.vault-autocommit = {
    description = "Vault auto-commit to git";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/auto-commit.sh";
    };
  };

  systemd.user.timers.vault-autocommit = {
    description = "Vault auto-commit every 30 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:00/30";
      Persistent = true;
    };
  };

  systemd.user.services.vault-backup = {
    description = "Vault backup to Google Drive via rclone";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone sync /home/michael/vault gdrive:vault-backup \
          --exclude ".git/**" --exclude ".stversions/**" \
          --exclude ".qmd/**" --exclude "_agent/memory/working/**"
      '';
    };
  };

  systemd.user.timers.vault-backup = {
    description = "Nightly vault backup at 2 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-heartbeat-daily = {
    description = "Vault daily heartbeat (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-daily.sh";
    };
  };

  systemd.user.timers.vault-heartbeat-daily = {
    description = "Daily vault heartbeat at 6 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-heartbeat-weekly = {
    description = "Vault weekly deep review (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-weekly.sh";
    };
  };

  systemd.user.timers.vault-heartbeat-weekly = {
    description = "Weekly vault review Sunday 9 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 09:00:00";
      Persistent = true;
    };
  };
}
