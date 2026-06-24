# Vault (second/third brain) services and packages
{ config, pkgs, ... }:

let
  # PATH for systemd user services: include bash, git, claude, obsidian,
  # whisper-cli (voice transcription), ffmpeg (audio reformat), jq, curl,
  # and the bun-installed qmd binary.
  vaultServicePath = builtins.concatStringsSep ":" [
    "${pkgs.bash}/bin"
    "${pkgs.coreutils}/bin"
    "${pkgs.git}/bin"
    "${pkgs.obsidian}/bin"
    "${pkgs.bun}/bin"
    "${pkgs.whisper-cpp}/bin"
    "${pkgs.ffmpeg}/bin"
    "${pkgs.jq}/bin"
    "${pkgs.curl}/bin"
    "${config.users.users.michael.home}/.bun/bin"
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/michael/bin"
  ];

  # Whisper base.en model (~148 MB) pinned for voice memo transcription via
  # the Telegram listener. Fetched once, lives at a stable nix store path,
  # passed to the listener via WHISPER_MODEL env var.
  whisperModelBaseEn = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };
in
{
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    rclone
    obsidian
    bun           # for qmd maintenance (qmd update, qmd embed)
    whisper-cpp   # voice memo transcription for Telegram listener
    ffmpeg        # convert Telegram .ogg to whisper-friendly .wav
    jq            # Telegram listener JSON parsing
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
    guiAddress = "0.0.0.0:8384";   # listen on all interfaces (tailnet trusted)
  };

  # Open Syncthing GUI port for localhost-only access
  networking.firewall.allowedTCPPorts = [ 8384 ];

  # ── User systemd services ────────────────────────────────────────
  # All vault services share the same PATH so scripts can find bash,
  # git, claude, obsidian, bun, etc.

  systemd.user.services.vault-autocommit = {
    description = "Vault auto-commit to git";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/auto-commit.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
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
      Environment = [ "PATH=${vaultServicePath}" ];
      ExecStart = pkgs.writeShellScript "vault-backup" ''
        if ! ${pkgs.rclone}/bin/rclone listremotes | grep -q '^gdrive:'; then
          echo "vault-backup: gdrive remote not configured. Run 'rclone config' to enable. Skipping."
          exit 0
        fi
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

  # ── Three-times-daily heartbeat ──────────────────────────────
  # Morning (6 AM):  briefing + memory hygiene
  # Noon (12 PM):    midday pulse, what changed since morning
  # Night (10 PM):   inbox processing + reflection (heaviest)
  # Each fires Claude Agent SDK via OAuth, bills against $100/mo Max pool.

  systemd.user.services.vault-heartbeat-morning = {
    description = "Vault heartbeat — morning briefing (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-morning.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-heartbeat-morning = {
    description = "Morning vault heartbeat at 6 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-heartbeat-noon = {
    description = "Vault heartbeat — midday pulse (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-noon.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-heartbeat-noon = {
    description = "Midday vault pulse at 12 PM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-heartbeat-night = {
    description = "Vault heartbeat — night ingest + reflection (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-night.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-heartbeat-night = {
    description = "Night vault reflection + inbox processing at 10 PM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 22:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-heartbeat-weekly = {
    description = "Vault weekly deep review (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/heartbeat-weekly.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
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

  # ── Dream consolidation (continuous memory maintenance) ──────
  # Tiered "dreaming" over the vault: prune stale / merge dupes / synthesize
  # insights with provenance / supersede changed facts + retrieval analytics.
  # Propose-first — judgment-bound changes land in _agent/dream/review-queue.md
  # and Michael approves via /vault. Safe, reversible fixes apply directly.
  # See 10-projects/vault-dream-consolidation.md for the full design.
  #   nightly (23:00, after the night heartbeat): light dedup + retrieval heat
  #   weekly  (Sun 11:00, after the weekly review): synthesis + merges + supersession + stale
  #   monthly (1st, 03:30): MOC regen + decay sweep + dashboard + qmd embed

  systemd.user.services.vault-dream-nightly = {
    description = "Vault dream — nightly light consolidation (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/dream-nightly.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-dream-nightly = {
    description = "Nightly vault dream at 11 PM (after the night heartbeat)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 23:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-dream-weekly = {
    description = "Vault dream — weekly deep consolidation (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/dream-weekly.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-dream-weekly = {
    description = "Weekly deep dream Sunday 11 AM (after the weekly review)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 11:00:00";
      Persistent = true;
    };
  };

  systemd.user.services.vault-dream-monthly = {
    description = "Vault dream — monthly graph rollup (Claude Agent SDK)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/dream-monthly.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-dream-monthly = {
    description = "Monthly vault dream rollup on the 1st at 03:30";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-01 03:30:00";
      Persistent = true;
    };
  };

  # ── Telegram bridge ──────────────────────────────────────────
  # Long-polling listener for @NixieVMBot: captures inbound text /
  # voice (whisper-cli transcribed) / photo / file to 00-inbox/.
  # Handles slash commands (/morning /yesterday /ask /help).

  systemd.user.services.vault-telegram-listener = {
    description = "Vault Telegram listener (capture inbound + slash commands)";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "/home/michael/vault/.scripts/telegram-listener.sh";
      Environment = [
        "PATH=${vaultServicePath}"
        "WHISPER_MODEL=${whisperModelBaseEn}"
      ];
    };
  };

  # Evening reflection ping at 21:00 — bot prompts a question;
  # reply lands back in 00-inbox/ via the listener.

  systemd.user.services.vault-evening-prompt = {
    description = "Vault evening reflection prompt → Telegram";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/michael/vault/.scripts/evening-prompt.sh";
      Environment = [ "PATH=${vaultServicePath}" ];
    };
  };

  systemd.user.timers.vault-evening-prompt = {
    description = "Fire evening reflection at 21:00 daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 21:00:00";
      Persistent = true;
    };
  };
}
