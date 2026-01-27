# Homebrew integration for macOS
# Manages GUI applications that aren't available or work better via Homebrew
{ ... }: {
  homebrew = {
    enable = true;

    # Update Homebrew and upgrade all packages on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Remove packages not listed here
      cleanup = "zap";
    };

    # Homebrew taps (add additional taps here if needed)
    taps = [
    ];

    # CLI tools from Homebrew (prefer nixpkgs when possible)
    brews = [
      # Add any CLI tools that work better from Homebrew here
    ];

    # GUI applications via Homebrew Casks
    casks = [
      # Window management and productivity
      "bettertouchtool"
      "alfred"

      # Security
      "1password"

      # Development
      "docker-desktop"
      "ghostty"
      "thonny"           # Python IDE for beginners

      # Keyboard customization
      "karabiner-elements"
      "keycastr"         # Show keystrokes on screen

      # Media
      "vlc"

      # Utilities (existing)
      "obsidian"         # Note-taking
      "balenaetcher"     # USB image writer

      # Additional utilities
      "gimp"             # Image editor
      "notunes"          # Prevents Music app from launching

      # Recommended utilities
      "stats"            # System monitor in menu bar
      "the-unarchiver"   # Archive extraction
      "appcleaner"       # Clean app removal
      "monitorcontrol"   # External monitor brightness/volume
    ];

    # Mac App Store apps (requires mas CLI and being signed into App Store)
    # masApps = {
    #   "Xcode" = 497799835;
    #   "Amphetamine" = 937984704;
    # };
  };
}
