{ pkgs, ... }:

{
  networking.hostName = "nixie-vm";

  # Nix settings (flakes, git for fetching)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    git
    claude-code  # Claude CLI tool
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # User account for VM (simplified from laptop users.nix)
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.defaultUserShell = pkgs.zsh;

  # Basic programs
  programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Printing support
  services.printing.enable = true;

  # Polkit for privilege escalation dialogs
  security.polkit.enable = true;

  system.stateVersion = "25.11";
}
