{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./keyd
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-77a6df21-58f4-4c91-84c0-7ac231e5208d".device = "/dev/disk/by-uuid/77a6df21-58f4-4c91-84c0-7ac231e5208d";
  networking.hostName = "nixos"; # Define your hostname.

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

  };

  # Security Settings
  security.polkit.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

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
    layout = "us";
  };

  # Enable the gdm.
  services.xserver.displayManager.gdm.enable = true;
  # Enable hyprland window manager
  programs.hyprland.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  callofduty
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  # Install firefox.
  programs.firefox.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "michael" ];
  };
  programs.zsh.enable = true;
#  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    bat
    cmatrix
    cowsay
    dunst
    ffmpeg
    figlet
    fzf
    git
    gnome.gnome-tweaks
    grim
    htop
    kitty
    noto-fonts 
    playerctl 
    libnotify
    neofetch
    neovim
    pipes
    playerctl
    polkit_gnome    
    ranger
    rofi-wayland
    rofimoji
    slurp
    swaybg
    swaynotificationcenter
    tmux
    vim
    vlc
    waybar
    wev
    wget
    wl-clipboard
    xdg-desktop-portal-hyprland
    xsel
    zsh
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    open-sans
    font-awesome
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Source Han Serif" ];
    sansSerif = [ "Open Sans" "Source Han Sans" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.enableDefaultPackages = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
     battery = {
     governor = "powersave";
     turbo = "never";
    };
     charger = {
     governor = "performance";
     turbo = "auto";
    };
  };

  system.stateVersion = "23.11";

}

