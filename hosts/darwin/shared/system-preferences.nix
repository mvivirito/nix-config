# macOS System Preferences
# Configures Dock, Finder, keyboard, trackpad, and other system settings
{ ... }: {
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      orientation = "bottom";
      tilesize = 48;
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false;  # Don't rearrange spaces based on recent use
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";  # Search current folder by default
      FXPreferredViewStyle = "Nlsv";  # List view
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };

    # Global keyboard settings
    # Note: Caps Lock remapping handled by Karabiner-Elements
    NSGlobalDomain = {
      # Key repeat settings
      KeyRepeat = 2;  # Fast key repeat
      InitialKeyRepeat = 15;  # Short delay until repeat

      # Disable press-and-hold for special characters (enables key repeat)
      ApplePressAndHoldEnabled = false;

      # Enable full keyboard access for all controls
      AppleKeyboardUIMode = 3;

      # Disable auto-correct and other text substitutions
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;

      # Use scroll gesture with Ctrl to zoom
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      AppleEnableSwipeNavigateWithScrolls = true;
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;  # Tap to click
      TrackpadRightClick = true;  # Two finger right click
      TrackpadThreeFingerDrag = false;  # Three finger drag
    };

    # Screenshots
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    # Login window
    loginwindow = {
      GuestEnabled = false;
    };

    # Spaces
    spaces = {
      spans-displays = false;  # Displays have separate Spaces
    };

    # Menu bar
    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = false;
    };
  };

  # Additional system settings via activation script
  system.activationScripts.postActivation.text = ''
    # Disable the sound effects on boot
    nvram SystemAudioVolume=" " || true

    # Save to disk (not to iCloud) by default
    sudo -u mvivirito defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable Resume system-wide
    sudo -u mvivirito defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

    # Show the ~/Library folder
    chflags nohidden /Users/mvivirito/Library || true

    # Create Screenshots folder if it doesn't exist
    sudo -u mvivirito mkdir -p /Users/mvivirito/Pictures/Screenshots
  '';
}
