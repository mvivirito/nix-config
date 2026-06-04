{ lib, ... }:

{
  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = [ "nix-command" "flakes" ];

    # Hard-link identical files in the store to save disk (dedup on every build).
    # Run `nix store optimise` once to dedupe the existing 113 GB store.
    auto-optimise-store = true;

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
}
