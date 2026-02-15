{ pkgs, ... }:

{
  # Host-specific configuration for nixos-laptop

  # Hostname
  networking.hostName = "nixos-laptop";

  # Intel Iris Xe (11th gen Tiger Lake) hardware video acceleration
  # Required for Moonlight, mpv, Firefox, etc. to use GPU decoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API driver for Gen 8+ Intel (iHD)
      vpl-gpu-rt            # Intel Video Processing Library (QSV successor)
    ];
  };

  # LUKS encryption device
  boot.initrd.luks.devices."luks-77a6df21-58f4-4c91-84c0-7ac231e5208d".device = "/dev/disk/by-uuid/77a6df21-58f4-4c91-84c0-7ac231e5208d";

  # Host-specific overrides can be added here
  # Examples:
  # - Additional hardware-specific kernel modules
  # - Machine-specific services
  # - Performance tuning for this specific hardware
}
