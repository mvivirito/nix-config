{ config, lib, pkgs, ... }:

{
  options.vm.gpu = {
    enable = lib.mkEnableOption "GPU passthrough";
    nvidia.enable = lib.mkEnableOption "NVIDIA drivers";
  };

  config = lib.mkIf config.vm.gpu.enable {
    # Disable VirtIO GPU and SPICE when using passthrough
    boot.blacklistedKernelModules = [ "virtio_gpu" ];
    services.spice-vdagentd.enable = lib.mkForce false;

    # NVIDIA driver configuration
    services.xserver.videoDrivers = lib.mkIf config.vm.gpu.nvidia.enable [ "nvidia" ];

    hardware.nvidia = lib.mkIf config.vm.gpu.nvidia.enable {
      open = true;  # Use open kernel modules (RTX 40 compatible)
      modesetting.enable = true;
      powerManagement.enable = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Headless X11 configuration for GPU passthrough without physical monitor
    # BusID forces X to use the passthrough GPU (adjust if your GPU is on different bus)
    services.xserver.deviceSection = lib.mkIf config.vm.gpu.nvidia.enable ''
      BusID "PCI:1:0:0"
      Option "AllowEmptyInitialConfiguration" "true"
      Option "ConnectedMonitor" "DP-0"
      Option "UseDisplayDevice" "DP-0"
    '';

    # Virtual display at 1080p - Sunshine will capture this
    services.xserver.screenSection = lib.mkIf config.vm.gpu.nvidia.enable ''
      Option "MetaModes" "1920x1080"
    '';

    # Add NVIDIA-specific packages to graphics stack (merges with base.nix)
    hardware.graphics.extraPackages = lib.mkIf config.vm.gpu.nvidia.enable (with pkgs; [
      nvidia-vaapi-driver
    ]);

    boot.kernelParams = lib.mkIf config.vm.gpu.nvidia.enable [
      "nvidia-drm.modeset=1"
    ];

    # NVIDIA monitoring tools
    environment.systemPackages = lib.mkIf config.vm.gpu.nvidia.enable (with pkgs; [
      nvtopPackages.nvidia
      pciutils  # lspci for debugging
    ]);
  };
}
