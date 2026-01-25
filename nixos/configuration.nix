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
    ./keyd
    ./theme.nix
    ./niri.nix
  ];

  # Nix configuration
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep generations for 365 days to provide a larger safety net
      options = "--delete-older-than 365d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Minimal system packages - only essentials for system administration
  # All user applications are now in home-manager for better portability
  environment.systemPackages = with pkgs; [
    vim              # Emergency editor if home-manager breaks
    git              # To clone/update this config repository
    claude-code      # System-level claude-code installation
  ];

  # NixOS state version - DO NOT CHANGE
  # This is NOT the NixOS version, it's a state compatibility marker
  system.stateVersion = "23.11";
}
