# MacBook-specific configuration
{
  hostname,
  ...
}: {
  # Set the hostname
  networking.hostName = hostname;
  networking.computerName = hostname;

  # MacBook-specific settings can go here
  # For example, different power management, specific hardware configs, etc.
}
