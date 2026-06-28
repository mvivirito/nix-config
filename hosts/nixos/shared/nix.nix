{ lib, ... }:

{
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = [ "nix-command" "flakes" ];

    # Hard-link identical files in the store to save disk (dedup on every build).
    # Run `nix store optimise` once to dedupe the existing 113 GB store.
    auto-optimise-store = true;

    # Auto-GC during builds: when free space drops below min-free, the daemon
    # deletes store garbage until max-free is available. Stops a single large
    # build from wedging the disk at 100% (how nixie-vm once died mid-rebuild).
    # Note: this only reclaims unreferenced paths, not old generations — the
    # nix.gc timer below handles those. Values in bytes.
    min-free = 5 * 1024 * 1024 * 1024; # 5 GiB
    max-free = 20 * 1024 * 1024 * 1024; # 20 GiB

    # Binary caches (official + community)
    substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Baseline automatic generation cleanup for every NixOS host. mkDefault so a
  # host can tighten it (the VM runs daily/7d in vm/base.nix). Without this,
  # generations accumulate forever — nixie-vm once hit 2168 and filled its disk.
  # The laptop keeps its own explicit policy in nixos/configuration.nix, which
  # overrides this default.
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 30d";
  };
}
