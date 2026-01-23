# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # Cross-platform core configuration (works on Linux, macOS, BSD, etc.)
    ./core/cli-tools.nix
    ./core/terminals.nix
    ./core/neovim
    ./core/zsh.nix
    ./core/kitty.nix
    ./core/ranger.nix

    # Platform-agnostic but currently only used on Linux
    ./appearance.nix

    # Linux-specific configuration (Wayland, X11, desktop environment)
    # Imported unconditionally, will use mkIf inside modules if needed for cross-platform
    ./linux/gui-apps.nix
    ./linux/hyprland
    ./linux/waybar
    ./linux/rofi.nix
    ./linux/tofi.nix
  ];

  # Note: nixpkgs config is disabled when using home-manager as NixOS module with useGlobalPkgs
  # The system nixpkgs config (in nixos/configuration.nix) is used instead
  # nixpkgs = {
  #   overlays = [ ];
  #   config = {
  #     allowUnfree = true;
  #     allowUnfreePredicate = _: true;
  #   };
  # };

  home = {
    username = "michael";
    homeDirectory = "/home/michael";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
#    NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
    XCURSOR_SIZE = "32";
    HYPRCURSOR_SIZE = "32";
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  wayland.windowManager.hyprland.enable = true; 
  
  services.playerctld.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };

  # Idle management with swayidle
  # Handles automatic screen locking and DPMS (display power management)
  #
  # Timeout 1 (10 seconds): Turn off display IF already locked
  # - Prevents screen burn-in when locked
  # - Only runs if swaylock is active (pgrep check)
  # - Resume turns display back on
  #
  # Timeout 2 (930 seconds = 15.5 min): Lock screen
  # - Runs swaylock with background image
  # - -f: fork to background, -F: show even if no password yet
  # - Same timeout as hibernate (coordinated behavior)
  #
  # Timeout 3 (930 seconds): Turn off display when locked
  # - Runs simultaneously with Timeout 2
  # - Saves power after locking
  # - Resume turns display back on
  #
  # Why two 930-second timeouts?
  # - Timeout 2: triggers lock
  # - Timeout 3: triggers DPMS after lock
  # - They race, but lock completes first (milliseconds)
  # - Result: Screen locks, then immediately powers off
  #
  # Coordination with hibernate.nix:
  # - 930 seconds matches HIBERNATE_SECONDS
  # - After 15.5 min: lock + DPMS + hibernate (if on battery)
  # - User sees: idle → lock → screen off → (RTC wake) → hibernate

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      {
        timeout = 10;  # 10 seconds
        command = "if pgrep -x swaylock; then hyprctl dispatch dpms off; fi";
        resumeCommand = "hyprctl dispatch dpms on";
      }
      {
        timeout = 930;  # 15.5 minutes - lock screen
        command = "${pkgs.swaylock}/bin/swaylock -i /home/michael/Pictures/lock_background.jpg -fF";
      }
      {
        timeout = 930;  # 15.5 minutes - power off display
        command = "hyprctl dispatch dpms off";
        resumeCommand = "hyprctl dispatch dpms on";
      }
    ];
    # Events for suspend/resume - these use systemd's inhibitor locks
    # before-sleep: Lock screen BEFORE system suspends (security)
    # Uses -w flag via extraArgs to wait for lock before releasing inhibitor
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -i /home/michael/Pictures/lock_background.jpg -fF";
      }
    ];
    extraArgs = [ "-w" ];  # Wait for commands to finish before sleep
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
