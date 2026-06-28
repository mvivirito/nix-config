# Syncthing for the m1 server — joins the existing Obsidian-vault mesh
# (nixie-vm <-> Android <-> laptops) as a normal read-write peer.
#
# Runs as a home-manager user launchd agent (lives in the logged-in GUI session).
# The vault is at ~/vault (NOT in iCloud — Syncthing owns this folder outright).
# A separate Unison bridge (./unison-vault.nix) reconciles ~/vault with the iCloud
# Obsidian container so Obsidian on iOS gets the vault. Keeping Syncthing and iCloud
# on SEPARATE folders is what avoids the two-engine conflict storm.
#
# Devices/folders are paired at runtime via the web UI / CLI; override* = false so
# home-manager never clobbers that. Reach the UI over SSH:
#   ssh -L 8384:localhost:8384 michaelvivirito@m1.local
{ ... }: {
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
  };
}
