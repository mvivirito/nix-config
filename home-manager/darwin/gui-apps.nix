# macOS GUI applications managed by home-manager
# Note: Some GUI apps work better via Homebrew casks (see hosts/darwin/shared/homebrew.nix)
# VLC, Spotify, Discord etc. should be installed via Homebrew casks on macOS
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Development
    vscode
  ];

  # macOS-specific program configurations can go here
}
