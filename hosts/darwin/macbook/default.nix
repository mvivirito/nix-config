# MacBook-specific configuration
{
  hostname,
  pkgs,
  ...
}: {
  # Set the hostname
  networking.hostName = hostname;
  networking.computerName = hostname;

  # Claude Code CLI for personal machine
  environment.systemPackages = with pkgs; [
    claude-code
  ];

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
