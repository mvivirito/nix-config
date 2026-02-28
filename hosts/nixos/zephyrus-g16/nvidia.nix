{ config, lib, pkgs, ... }:

{
  # NVIDIA RTX 4090 Mobile + Intel Arc hybrid graphics (PRIME offload)
  # Intel Arc handles display output and battery-efficient tasks
  # NVIDIA RTX 4090 available on-demand via nvidia-offload command

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Use open-source kernel modules (required for RTX 40 series)
    open = true;

    # Enable kernel modesetting (required for Wayland)
    modesetting.enable = true;

    # Power management for suspend/resume
    powerManagement.enable = true;

    # Fine-grained power management (RTX 20+ Turing)
    # Turns off GPU when not in use
    powerManagement.finegrained = true;

    # PRIME offload mode: Intel Arc renders by default, NVIDIA on-demand
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;  # Provides nvidia-offload command
      };

      # PCI Bus IDs (confirmed via lspci)
      intelBusId = "PCI:0:2:0";   # Intel Arc iGPU
      nvidiaBusId = "PCI:1:0:0";  # NVIDIA RTX 4090 Mobile
    };

    # Use production driver (not beta)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # Environment variables for Wayland with NVIDIA
  environment.sessionVariables = {
    # Use NVIDIA GBM backend for Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Help Electron apps with NVIDIA
    LIBVA_DRIVER_NAME = "nvidia";

    # Cursor fix for some Wayland compositors
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # NVIDIA suspend/resume: preserve video memory allocations across sleep
  boot.extraModprobeConfig = ''
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
  '';

  # Note: nvidia-suspend/resume systemd services are automatically
  # created by hardware.nvidia.powerManagement.enable = true

  # CUDA support
  hardware.nvidia-container-toolkit.enable = true;

  # Packages for NVIDIA utilities
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia  # GPU monitoring
    nvidia-vaapi-driver   # VA-API for NVIDIA
  ];
}
