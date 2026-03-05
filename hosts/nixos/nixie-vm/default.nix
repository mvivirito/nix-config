{ pkgs, ... }:

{
  networking.hostName = "nixie-vm";

  # GPU passthrough - enabled for NVIDIA RTX
  vm.gpu.enable = true;
  vm.gpu.nvidia.enable = true;

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
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Enable Podman for container management
  virtualisation.podman = {
    enable = true;
    # Create a `docker` alias for podman, for cli compatibility
    dockerCompat = true;
  };

  # User account for VM (simplified from laptop users.nix)
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "render" ];
  };

  users.defaultUserShell = pkgs.zsh;

  # Basic programs
  programs.zsh.enable = true;

  # Printing support
  services.printing.enable = true;

  # Polkit for privilege escalation dialogs
  security.polkit.enable = true;

  # NFS mount from NAS
  services.rpcbind.enable = true;

  fileSystems."/mnt/harbor" = {
    device = "10.0.0.108:/volume1/harbor";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "soft"
      "timeo=30"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  system.stateVersion = "25.11";
}
