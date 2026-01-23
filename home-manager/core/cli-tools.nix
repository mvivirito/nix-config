{ pkgs, ... }:

{
  # Cross-platform CLI tools that work on Linux, macOS, and any Unix-like system
  # These are essential command-line utilities that enhance productivity

  home.packages = with pkgs; [
    # File and text processing
    bat              # Better cat with syntax highlighting
    ripgrep          # Fast grep replacement (rg)
    fzf              # Fuzzy finder

    # Git and version control
    git
    lazygit          # Terminal UI for git

    # System utilities
    htop             # Process viewer
    neofetch         # System info display
    tmux             # Terminal multiplexer
    wget             # Download utility

    # Development tools
    clang            # C/C++ compiler (works cross-platform)

    # Media and conversion
    ffmpeg           # Video/audio processing
    yt-dlp           # YouTube downloader

    # Fun terminal programs
    cmatrix          # Matrix rain
    cool-retro-term  # Retro terminal emulator
    cowsay           # ASCII cow
    figlet           # ASCII art text
    pipes            # Animated pipes screensaver
  ];
}
