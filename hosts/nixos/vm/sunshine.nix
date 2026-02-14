{ config, lib, pkgs, ... }:

{
  # Sunshine game streaming server (Moonlight client compatible)
  # WebGUI: https://localhost:47990
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;  # Required for KMS/Wayland capture
  };

  # Avahi for mDNS discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
