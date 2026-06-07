{ pkgs, lib, inputs, ... }:

{
  # Core configuration (cross-platform CLI tools)
  imports = [
    # Prebuilt nix-index database (command-not-found + comma)
    inputs.nix-index-database.homeModules.nix-index

    ../../../home-manager/core/cli-tools.nix
    ../../../home-manager/core/terminals.nix
    ../../../home-manager/core/neovim
    ../../../home-manager/core/zsh.nix
    ../../../home-manager/core/kitty.nix
    ../../../home-manager/core/tmux.nix
    ../../../home-manager/linux/kde-gui-apps.nix
    # Skip: niri, dms, appearance.nix - VM uses KDE
  ];

  # Disable zoxide on this VM; use the plain `cd` builtin (no smart-jump on a server).
  programs.zoxide.enable = lib.mkForce false;

  home = {
    username = "michael";
    homeDirectory = "/home/michael";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
  };

  # nixie-vm specific packages
  home.packages = (with pkgs; [
    gemini-cli        # Google Gemini AI CLI
    kubectl           # Kubernetes command-line tool
    kubernetes-helm   # The Kubernetes package manager
    k9s               # Kubernetes CLI To Manage Your Clusters In Style!
    awscli2           # AWS CLI v2
    terraform         # Infrastructure as Code (HashiCorp)
    opentofu          # Open-source Terraform fork
  ]) ++ [
    inputs.gws.packages.x86_64-linux.gws  # Google Workspace CLI
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
