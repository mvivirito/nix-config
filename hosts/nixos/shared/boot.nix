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

  # Full Magic SysRq on both physical laptops (kernel default is 16 = sync only).
  # If the GUI/GPU locks up but the kernel is alive, this allows a *clean* emergency
  # reboot (hold Alt+SysRq, tap R-E-I-S-U-B) instead of a power-button hard cut that
  # risks FS/app corruption. Lives here because both laptops import shared/boot.nix
  # and both want it; the VMs boot via hosts/nixos/vm/base.nix and aren't affected.
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
