{ pkgs, ... }:

{
  imports = [
    ./flutter-dev.nix  # Flutter + Android SDK for mobile development
    ./vault.nix        # Second/third brain: Syncthing, rclone, vault automation timers
  ];

  networking.hostName = "nixie-vm";

  # GPU passthrough - enabled for NVIDIA RTX
  vm.gpu.enable = true;
  vm.gpu.nvidia.enable = true;

  environment.systemPackages = with pkgs; [
    git
    claude-code  # Claude CLI tool
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Accept Android SDK licenses (required for Flutter/Android development)
  nixpkgs.config.android_sdk.accept_license = true;

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
    # "uinput" is required for Sunshine to create virtual kbd/mouse/gamepad:
    # hardware.uinput (auto-enabled by services.sunshine) makes /dev/uinput
    # group "uinput", not "input" — without this, Moonlight shows the desktop
    # but no input works ("Permission denied" creating virtual devices).
    extraGroups = [ "networkmanager" "wheel" "input" "uinput" "video" "render" ];
  };

  users.defaultUserShell = pkgs.zsh;

  # Basic programs
  programs.zsh.enable = true;

  # Printing support
  services.printing.enable = true;

  # Polkit for privilege escalation dialogs
  security.polkit.enable = true;

  system.stateVersion = "25.11";
}
