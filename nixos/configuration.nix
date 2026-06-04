{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    # Host-specific configuration
    ../hosts/nixos/laptop/hardware.nix
    ../hosts/nixos/laptop/default.nix

    # Shared NixOS system modules
    ../hosts/nixos/shared/boot.nix
    ../hosts/nixos/shared/locale.nix
    ../hosts/nixos/shared/networking.nix
    ../hosts/nixos/shared/audio.nix
    ../hosts/nixos/shared/fonts.nix
    ../hosts/nixos/shared/users.nix
    ../hosts/nixos/shared/power.nix
    ../hosts/nixos/shared/hibernate.nix

    # System-specific modules
    ./greetd.nix
    ./kanata
    ./theme.nix
    ./niri.nix
  ];

  # Nix configuration
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # 4c/8t CPU + 16 GB RAM: cap concurrent derivations and threads-per-build
      # so a local build (cache miss) can't oversubscribe CPU or OOM.
      max-jobs = 4;
      cores = 2;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep 30 days of generations. configurationLimit (boot.nix) caps the boot
      # menu at 10; this bounds on-disk generations so weekly GC actually frees space.
      options = "--delete-older-than 30d";
    };
  };

  # nh: friendlier nixos-rebuild wrapper with a build diff (`nh os switch`).
  # GC stays handled by nix.gc above, so nh.clean is intentionally left off.
  programs.nh = {
    enable = true;
    flake = "/home/michael/nix-config";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Minimal system packages - only essentials for system administration
  # All user applications are now in home-manager for better portability
  environment.systemPackages = with pkgs; [
    vim              # Emergency editor if home-manager breaks
    git              # To clone/update this config repository
    claude-code      # System-level claude-code installation
    gemini-cli
  ];

  # NixOS state version - DO NOT CHANGE
  # This is NOT the NixOS version, it's a state compatibility marker
  system.stateVersion = "23.11";
}
