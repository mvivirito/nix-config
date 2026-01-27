# MacBook-specific configuration
{
  hostname,
  ...
}: {
  # Set the hostname
  networking.hostName = hostname;
  networking.computerName = hostname;

  # Personal machine apps (not installed on work machine)
  homebrew.casks = [
    # Communication
    "discord"
    "spotify"
    "claude"

    # Browsers
    "google-chrome"
    "firefox"
    "brave-browser"
  ];
}
