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
    ./core/tmux.nix

    # Platform-agnostic but currently only used on Linux
    ./appearance.nix

    # Linux-specific configuration (Wayland desktop environment)
    # Niri compositor + Dank Material Shell
    ./linux/gui-apps.nix
    ./linux/niri
    ./linux/dms.nix
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
    BROWSER = "firefox";
    XCURSOR_SIZE = "32";
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

  services.playerctld.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
    };
  };

  # Idle management is now handled by DMS (Dank Material Shell)
  # See linux/dms.nix for lock/idle configuration

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
