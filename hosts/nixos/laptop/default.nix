{ pkgs, ... }:

{
  # Host-specific configuration for nixos-laptop

  # Hostname
  networking.hostName = "nixos-laptop";

  # Intel Iris Xe (11th gen Tiger Lake) hardware video acceleration
  # Required for Moonlight, mpv, Firefox, etc. to use GPU decoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API driver for Gen 8+ Intel (iHD)
      vpl-gpu-rt            # Intel Video Processing Library (QSV successor)
    ];
  };

  # LUKS encryption device
  boot.initrd.luks.devices."luks-77a6df21-58f4-4c91-84c0-7ac231e5208d".device = "/dev/disk/by-uuid/77a6df21-58f4-4c91-84c0-7ac231e5208d";

  services.syncthing = {
    enable = true;
    user = "michael";
    group = "users";
    dataDir = "/home/michael";
    configDir = "/home/michael/.config/syncthing";
    openDefaultPorts = true;      # TCP 22000, UDP 21027
    overrideDevices = false;      # allow GUI device pairing
    overrideFolders = false;      # allow GUI folder pairing
  };

  # --- Power & thermal (Tiger Lake ThinkPad) ---

  # Compressed RAM swap: absorbs memory pressure on the 16 GB machine without
  # hammering the SSD. The encrypted disk swap stays the hibernate/resume device.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Intel display power saving. FBC (framebuffer compression) is safe on Tiger
  # Lake and saves idle-display power. (PSR can flicker on some panels — left off.)
  boot.kernelParams = [ "i915.enable_fbc=1" ];

  # Cap battery charge at 80% on AC to slow lithium-ion wear when desk-bound.
  # Raise both to 100 before travel for full runtime.
  systemd.services.battery-charge-threshold = {
    description = "Limit battery charge to 80% for longevity";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
  };

  # Default power-profiles-daemon to "balanced" at boot (it otherwise persists
  # "performance"). Bump to performance from the DMS control center when needed.
  systemd.services.default-power-profile = {
    description = "Set power-profiles-daemon to balanced at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
    };
  };
}
