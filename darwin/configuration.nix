# Main nix-darwin configuration
# This is the entrypoint for macOS system configuration
{
  inputs,
  outputs,
  pkgs,
  hostname,
  username ? "mvivirito",
  ...
}: {
  imports = [
    # Host-specific configuration
    ../hosts/darwin/${hostname}

    # Shared darwin modules
    ../hosts/darwin/shared/system-preferences.nix
    ../hosts/darwin/shared/fonts.nix
    ../hosts/darwin/shared/homebrew.nix
  ];

  # Primary user for system defaults and homebrew
  system.primaryUser = username;

  # Nix settings
  nix = {
    settings = {
      # Enable flakes and new nix command
      experimental-features = ["nix-command" "flakes"];
    };

    # Automatic store optimization
    optimise.automatic = true;

    # Garbage collection - clean up old generations
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages available to all users
  environment.systemPackages = with pkgs; [
    vim
    git
    claude-code
  ];

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Used for backwards compatibility, read the changelog before changing
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";
}
