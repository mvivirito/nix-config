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
    # Creates a virtual display that Sunshine can capture for streaming
    services.xserver.deviceSection = lib.mkIf config.vm.gpu.nvidia.enable ''
      BusID "PCI:1:0:0"
      Option "AllowEmptyInitialConfiguration" "true"
      Option "ConnectedMonitor" "DP-0"
      Option "UseEDID" "false"
      Option "ModeValidation" "NoEdidModes,NoMaxPClkCheck,NoHorizSyncCheck,NoVertRefreshCheck,NoVirtualSizeCheck"
    '';

    # Virtual display with multiple resolution options for headless streaming
    services.xserver.screenSection = lib.mkIf config.vm.gpu.nvidia.enable ''
      Option "MetaModes" "DP-0: 1920x1080_60 +0+0"
      Option "DPI" "96 x 96"
    '';

    # Monitor section to define the virtual display
    # Note: NixOS automatically adds "Identifier", don't duplicate it
    services.xserver.monitorSection = lib.mkIf config.vm.gpu.nvidia.enable ''
      Option "Enable" "true"
      HorizSync 30-100
      VertRefresh 50-75
      # Custom modelines for common resolutions
      Modeline "1920x1080_60" 148.50 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync
      Modeline "2560x1440_60" 241.50 2560 2608 2640 2720 1440 1443 1448 1481 +hsync +vsync
      Modeline "3840x2160_60" 533.00 3840 3888 3920 4000 2160 2163 2168 2222 +hsync +vsync
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
