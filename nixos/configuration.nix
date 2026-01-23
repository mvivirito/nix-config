{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./greetd.nix
      ./hardware-configuration.nix
      ./keyd
      ./theme.nix
      ./hibernate.nix
      ./hyprland.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.initrd.luks.devices."luks-77a6df21-58f4-4c91-84c0-7ac231e5208d".device = "/dev/disk/by-uuid/77a6df21-58f4-4c91-84c0-7ac231e5208d";
  networking.hostName = "nixos";

  # Power management.
  boot.kernelParams = [ "button.lid_init_state=open" ];

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


  security.polkit.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };

  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
      };
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable fingerprint reader
  services.fprintd.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # GNOME desktop disabled - using Hyprland instead
  # Keep gdk-pixbuf for image rendering support
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "keyd" "networkmanager" "wheel" ];
  };

  users.defaultUserShell = pkgs.zsh;

  programs.firefox.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "michael" ];
  };
  programs.zsh.enable = true;
  
  nixpkgs.config.allowUnfree = true;

  # Minimal system packages - only essentials for system administration
  # All user applications are now in home-manager for better portability
  environment.systemPackages = with pkgs; [
    vim              # Emergency editor if home-manager breaks
    git              # To clone/update this config repository
    claude-code      # System-level claude-code installation
  ];


  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    nerd-fonts.mononoki
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.enableDefaultPackages = true;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  system.stateVersion = "23.11";

}
