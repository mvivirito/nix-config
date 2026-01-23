{ ... }:

{
  # Host-specific configuration for nixos-laptop

  # Hostname
  networking.hostName = "nixos-laptop";

  # LUKS encryption device
  boot.initrd.luks.devices."luks-77a6df21-58f4-4c91-84c0-7ac231e5208d".device = "/dev/disk/by-uuid/77a6df21-58f4-4c91-84c0-7ac231e5208d";

  # Host-specific overrides can be added here
  # Examples:
  # - Additional hardware-specific kernel modules
  # - Machine-specific services
  # - Performance tuning for this specific hardware
}
