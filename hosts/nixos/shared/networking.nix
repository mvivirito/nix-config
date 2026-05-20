{ ... }:

{
  # Networking configuration
  networking.networkmanager.enable = true;

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--operator=michael" ];
  };

  # Trust the tailnet — any service bound to 0.0.0.0 becomes reachable
  # from peer devices on the tailnet without per-port firewall rules.
  # Tailnet is by definition a private network of your own devices.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
