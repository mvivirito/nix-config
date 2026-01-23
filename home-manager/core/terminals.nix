{ pkgs, ... }:

{
  # Terminal emulators - cross-platform
  # kitty and ghostty both work on Linux and macOS

  home.packages = with pkgs; [
    ghostty          # Modern GPU-accelerated terminal
    # kitty is configured separately in kitty.nix
  ];
}
