# Home-manager configuration for macOS (Darwin)
# This imports cross-platform core modules and darwin-specific configurations
{
  inputs,
  lib,
  config,
  pkgs,
  username ? "mvivirito",
  ...
}: {
  imports = [
    # Cross-platform core configuration
    ./core/cli-tools.nix
    ./core/terminals.nix
    ./core/neovim
    ./core/zsh.nix
    ./core/kitty.nix
    ./core/tmux.nix

    # Darwin-specific configuration
    ./darwin/gui-apps.nix
    ./darwin/karabiner
    ./darwin/aerospace.nix
    ./darwin/hammerspoon.nix
  ];

  home = {
    username = username;
    homeDirectory = lib.mkForce "/Users/${username}";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
