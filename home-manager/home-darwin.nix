# Home-manager configuration for macOS (Darwin)
# This imports cross-platform core modules and darwin-specific configurations
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Cross-platform core configuration
    ./core/cli-tools.nix
    ./core/terminals.nix
    ./core/neovim
    ./core/zsh.nix
    ./core/kitty.nix
    ./core/ranger.nix
    ./core/tmux.nix

    # Darwin-specific configuration
    ./darwin/gui-apps.nix
    ./darwin/karabiner
  ];

  home = {
    username = "mvivirito";
    homeDirectory = lib.mkForce "/Users/mvivirito";
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
