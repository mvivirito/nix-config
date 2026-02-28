{ pkgs, inputs, ... }:

{
  imports = [
    # Cross-platform core configuration
    ../../../home-manager/core/cli-tools.nix
    ../../../home-manager/core/git.nix
    ../../../home-manager/core/terminals.nix
    ../../../home-manager/core/neovim
    ../../../home-manager/core/zsh.nix
    ../../../home-manager/core/kitty.nix
    ../../../home-manager/core/tmux.nix

    # Linux desktop environment (Niri + DMS)
    ../../../home-manager/appearance.nix
    ../../../home-manager/linux/niri
    ../../../home-manager/linux/gui-apps.nix
    ../../../home-manager/linux/dms.nix
  ];

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

  # zephyrus-g16 specific packages
  home.packages = with pkgs; [
    discord
    obs-studio          # Streaming/recording with NVENC
    nvtopPackages.nvidia  # GPU monitoring
  ];

  # Enable home-manager
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

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.11";
}
