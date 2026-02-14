{ lib, pkgs, modulesPath, ... }:

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
      "virtio_gpu"  # VirtIO GPU support
      "sd_mod"
      "sr_mod"
    ];
    # Kernel modules for better graphics
    kernelModules = [ "virtio_gpu" ];

    # VM performance tuning
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.max_pool_percent=25"
    ];

    kernel.sysctl = {
      # Memory management tuning for VMs
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  # QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;

  # Spice/QEMU display support (when not using GPU passthrough)
  services.spice-vdagentd.enable = true;

  # Graphics acceleration for VMs (Mesa/Virgl for 3D)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # 32-bit support for compatibility
    extraPackages = with pkgs; [
      mesa
      libva           # VA-API for hardware video acceleration
      libva-utils     # vainfo for debugging
      libva-vdpau-driver  # VDPAU backend for VA-API
      libvdpau-va-gl  # VDPAU via OpenGL
      virglrenderer   # Better VirtIO GPU performance
    ];
  };

  # Environment variables for better VM graphics
  environment.sessionVariables = {
    # Use software rendering with LLVMpipe if Virgl unavailable
    LIBGL_ALWAYS_SOFTWARE = "0";  # Try hardware first
    # VA-API driver selection (auto-detect)
    LIBVA_DRIVER_NAME = "auto";
    # Gallium driver for VirtIO GPU
    GALLIUM_DRIVER = "virpipe";
  };

  # Disable laptop-specific services
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
  services.fprintd.enable = lib.mkForce false;
  services.fwupd.enable = lib.mkForce false;
}
