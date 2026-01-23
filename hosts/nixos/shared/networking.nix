{ ... }:

{
  # Networking configuration
  networking.networkmanager.enable = true;

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
}
