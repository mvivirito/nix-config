{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # VM boot configuration
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "sd_mod"
      "sr_mod"
    ];
  };

  # QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;

  # Spice/QEMU display support (when not using GPU passthrough)
  services.spice-vdagentd.enable = true;

  # Disable laptop-specific services
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
  services.fprintd.enable = lib.mkForce false;
  services.fwupd.enable = lib.mkForce false;
}
