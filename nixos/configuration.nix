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

  # Enable the sddm.
  #services.xserver.displayManager.sddm.enable = true; 
  services.xserver.desktopManager.gnome.enable = true;
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

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    xclip
    aerc
    adwaita-icon-theme
    baobab
    bat
    blueberry
    clang
    cmatrix
    cool-retro-term
    cowsay
    cliphist
    discord
    ffmpeg
    figlet
    floorp-bin
    fzf
    git
    gnome-boxes
    gnome-calculator
    gnome-clocks
    gnome-control-center
    gnome-system-monitor
    gnome-weather
    grim
    htop
    kitty
    ghostty
    lazygit
    libnotify
    libqalculate
    neofetch
    neovim
    nwg-displays
    pipes
    playerctl
    playerctl 
    polkit_gnome    
    ranger
    ripgrep
    rofi-calc
    rofimoji
    slurp
    spotify
    swaybg
    swayidle
    swaylock
    swaynotificationcenter
    tmux
    tofi
    vim
    vlc
    vscode
    waybar
    webcamoid
    wev
    wget
    wl-clipboard
    wl-color-picker
    wlr-randr
    wshowkeys
    xdg-desktop-portal-hyprland
    xfce.thunar
    xfce.tumbler
    xsel
    yt-dlp
    zsh
    wl-clip-persist
  ];


  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    nerd-fonts.mononoki
  ];  

  fonts.enableDefaultPackages = true;

  system.stateVersion = "23.11";

}
