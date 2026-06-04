{ ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  # Show the boot menu for 1s instead of the 5s default (hold a key to pause it).
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.graceful = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management: Keep lid state as open to avoid wake issues
  boot.kernelParams = [ "button.lid_init_state=open" ];
}
