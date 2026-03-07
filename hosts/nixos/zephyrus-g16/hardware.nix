{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Resume from hibernation image on LUKS swap partition
  boot.resumeDevice = "/dev/mapper/luks-6917e498-3306-44d3-9d59-acc0a318e716";
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/luks-0685abf7-7885-4a70-bd7a-f3f7514da3e5";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-0685abf7-7885-4a70-bd7a-f3f7514da3e5".device = "/dev/disk/by-uuid/0685abf7-7885-4a70-bd7a-f3f7514da3e5";
  boot.initrd.luks.devices."luks-6917e498-3306-44d3-9d59-acc0a318e716".device = "/dev/disk/by-uuid/6917e498-3306-44d3-9d59-acc0a318e716";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0542-1A4D";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/mapper/luks-6917e498-3306-44d3-9d59-acc0a318e716"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
