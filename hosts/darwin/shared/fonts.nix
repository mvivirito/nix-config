# Font packages for macOS
{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    # Nerd Fonts (coding fonts with icons)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only

    # Noto fonts (comprehensive Unicode coverage)
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Font Awesome (icons)
    font-awesome

    # Powerline symbols
    powerline-symbols
    powerline-fonts
  ];
}
