# Hardware configuration for nixie-vm (Proxmox VM)
# Note: Using label instead of UUID for portability when cloning
{ lib, ... }:

{
  # Root filesystem using label (set with: e2label /dev/sda1 root)
  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  # Swap file for memory pressure handling
  swapDevices = [{
    device = "/swapfile";
    size = 4096;  # 4GB
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
