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
    ./core/git.nix
    ./core/terminals.nix
    ./core/neovim
    ./core/zsh.nix
    ./core/kitty.nix
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
    GTK_THEME = "catppuccin-mocha-blue-standard";
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

  # Enable home-manager (git configured in core/git.nix)
  programs.home-manager.enable = true;
  dconf.enable = true;
  programs.neovim.enable = true;

  services.playerctld.enable = true;

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "alacritty -e nvim %F";
    terminal = false;
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/plain" "text/markdown" "application/json" "application/xml" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # PDF
      "application/pdf" = [ "sioyek.desktop" ];

      # Web
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];

      # Images
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];

      # Video
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];

      # Audio
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/x-m4a" = [ "mpv.desktop" ];

      # Text/code
      "text/plain" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "text/x-python" = [ "nvim.desktop" ];
      "text/x-shellscript" = [ "nvim.desktop" ];
      "application/json" = [ "nvim.desktop" ];
      "application/xml" = [ "nvim.desktop" ];
      "application/x-yaml" = [ "nvim.desktop" ];

    };
  };

  # Idle management is now handled by DMS (Dank Material Shell)
  # See linux/dms.nix for lock/idle configuration

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
