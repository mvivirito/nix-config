{ ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management: Keep lid state as open to avoid wake issues
  boot.kernelParams = [ "button.lid_init_state=open" ];
}
