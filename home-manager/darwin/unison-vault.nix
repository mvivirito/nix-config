# Unison bridge: two-way reconcile the Syncthing vault (~/vault) with the iCloud
# Obsidian container, so Obsidian on iOS gets read+write access.
#
# WHY A BRIDGE: Syncthing and iCloud can't both manage one folder (two engines →
# conflicts + resurrected deletes). So each owns its own folder and Unison bridges:
#   Syncthing mesh ──> ~/vault                       (Syncthing owns)
#                         ↕  Unison, every 60s
#   iCloud / iOS   ──> iCloud~md~obsidian/.../vault   (iCloud owns)
#
# WHY A FIXED-PATH BINARY COPY: macOS TCC blocks background launchd agents from
# iCloud (~/Library/Mobile Documents) unless the executable has Full Disk Access.
# A nix-store path changes on updates, breaking the FDA grant. The unison binary is
# fully self-contained (only links /usr/lib/libSystem), so we copy it ONCE to a
# stable path (~/.local/bin/unison-bridge) and grant FDA to THAT. It never changes,
# so the grant survives forever. One-time manual step after first rebuild:
#   System Settings → Privacy & Security → Full Disk Access → + →
#   ~/.local/bin/unison-bridge  (toggle ON)
# To update unison later: rm ~/.local/bin/unison-bridge, rebuild, re-grant FDA.
#
# Tuning that sidesteps iCloud's behaviour:
#   fastcheck = false  -> detect changes by CONTENT, not mtime (ignores iCloud's
#                         mtime churn); perms = 0 -> ignore the 0644<->0660 flips;
#   prefer = newer + backup = Name *  -> auto-resolve edit-conflicts, keep backups.
#
# TRADE-OFF: not real-time (60s). Same note edited on iOS and another device within
# one cycle → Unison keeps the newest and stashes the other in ~/.unison/backup.
{ config, pkgs, lib, ... }:
let
  home = config.home.homeDirectory;
  bridgeBin = "${home}/.local/bin/unison-bridge";
  vault = "${home}/vault";
  icloud = "${home}/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault";
  logDir = "${home}/Library/Logs";
in {
  home.packages = [ pkgs.unison ];

  # Stable, FDA-grantable copy of the (self-contained) unison binary. Copy-if-absent
  # so the path/cdhash — and therefore the Full Disk Access grant — never change.
  home.activation.unisonBridgeBinary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${bridgeBin}" ]; then
      $DRY_RUN_CMD mkdir -p "${home}/.local/bin"
      $DRY_RUN_CMD cp "${pkgs.unison}/bin/unison" "${bridgeBin}"
      $DRY_RUN_CMD chmod +x "${bridgeBin}"
    fi
  '';

  # Unison profile read as `unison vault` (-> ~/.unison/vault.prf). home.file
  # symlinks only this file; ~/.unison stays writable for archive/backups.
  home.file.".unison/vault.prf".text = ''
    root = ${vault}
    root = ${icloud}

    auto = true
    batch = true
    fastcheck = false
    perms = 0
    prefer = newer
    times = true
    backup = Name *
    maxbackups = 5

    ignore = Path .stfolder
    ignore = Path .stversions
    ignore = Path .git
    ignore = Name .DS_Store
    ignore = Name *.icloud

    log = true
    logfile = ${logDir}/unison-vault.log
  '';

  # Reconcile every 60s as a user agent (needs the GUI session for iCloud). Runs the
  # FIXED-PATH copy so its Full Disk Access grant stays valid across rebuilds.
  launchd.agents.unison-vault = {
    enable = true;
    config = {
      Label = "org.user.unison-vault";
      ProgramArguments = [ bridgeBin "vault" "-batch" ];
      WorkingDirectory = home;
      EnvironmentVariables = {
        HOME = home;
        UNISON = "${home}/.unison";
        # Pin the host identity: avoids an mDNS hostname lookup that can stall under
        # launchd, and keeps the archive name stable (no re-scan each run).
        UNISONLOCALHOSTNAME = "m1";
      };
      StartInterval = 60;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "${logDir}/unison-vault.out.log";
      StandardErrorPath = "${logDir}/unison-vault.err.log";
    };
  };
}
