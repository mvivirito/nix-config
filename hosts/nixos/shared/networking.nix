{ ... }:

{
  # Networking configuration
  networking.networkmanager.enable = true;

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Logind power management
  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
      };
    };
  };
}
