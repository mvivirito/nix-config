{ pkgs, lib, ... }:

{
  # Terminal emulators - cross-platform
  # kitty is configured separately in kitty.nix
  # ghostty via nixpkgs on Linux, via Homebrew on macOS

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    pkgs.ghostty     # Modern GPU-accelerated terminal (Linux only via nixpkgs)
  ];
}
