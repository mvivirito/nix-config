{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Browsers
    floorp-bin              # Firefox fork with vertical tabs
    brave               # Privacy-focused browser

    # Communication
    discord

    # Media
    vlc

    # Productivity
    vscode
    obsidian            # Note-taking

    # System utilities
    mission-center      # GTK4 system monitor
    yazi                # Terminal file manager
    playerctl           # Media control
  ];
}
