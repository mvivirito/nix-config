{ pkgs, lib, ... }:

{
  # Cross-platform CLI tools that work on Linux, macOS, and any Unix-like system
  # These are essential command-line utilities that enhance productivity

  home.packages = with pkgs; [
    # File and text processing
    bat              # Better cat with syntax highlighting
    ripgrep          # Fast grep replacement (rg)
    fd               # Fast find replacement
    fzf              # Fuzzy finder
    tree             # Directory tree view
    sd               # Simpler sed for find/replace
    jq               # JSON processor

    # Modern replacements for classic tools
    eza              # Modern ls with icons and git status
    dust             # Intuitive du alternative
    duf              # Better df with pretty output
    btop             # Beautiful htop replacement
    procs            # Modern ps
    delta            # Beautiful git diffs
    httpie           # Human-friendly curl
    ncdu             # Interactive disk usage analyzer
    gping            # Ping with live graph

    # Git and version control
    lazygit          # Terminal UI for git

    # System utilities
    fastfetch        # Fast system info display
    wget             # Download utility

    # Development tools
    clang            # C/C++ compiler (works cross-platform)
    tldr             # Simplified man pages with examples
    tokei            # Code statistics
    hyperfine        # CLI benchmarking

    # Media and conversion
    ffmpeg           # Video/audio processing
    yt-dlp           # YouTube downloader

    # Fun terminal programs
    cmatrix          # Matrix rain
    cowsay           # ASCII cow
    figlet           # ASCII art text
    pipes            # Animated pipes screensaver
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    cool-retro-term  # Retro terminal emulator
    bandwhich        # Bandwidth usage by process
  ];
}
