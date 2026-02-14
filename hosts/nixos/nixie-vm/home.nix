{ pkgs, ... }:

{
  # Core configuration (cross-platform CLI tools)
  imports = [
    ../../../home-manager/core/cli-tools.nix
    ../../../home-manager/core/terminals.nix
    ../../../home-manager/core/neovim
    ../../../home-manager/core/zsh.nix
    ../../../home-manager/core/kitty.nix
    ../../../home-manager/core/tmux.nix
    # Skip: niri, dms, appearance.nix - VM uses KDE
  ];

  home = {
    username = "michael";
    homeDirectory = "/home/michael";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
