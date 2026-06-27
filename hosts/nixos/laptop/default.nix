{ inputs, lib, config, pkgs, ... }:

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

  # Disable non-essential ACPI wake sources (USB / PCIe / Thunderbolt) so the
  # laptop can't wake itself in a bag and then sit awake draining the battery.
  # Keep LID + power button (SLPB) + RTC (AWAC — needed for the
  # suspend-then-hibernate timer). Writing a name to /proc/acpi/wakeup toggles
  # it, so only write when currently enabled (idempotent per boot).
  systemd.services.disable-wakeups = {
    description = "Disable spurious ACPI wakeup sources";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      while read -r name _ status _; do
        case " XHCI TRP1 TRP2 TXHC TDM0 TDM1 PEG0 " in
          *" $name "*)
            case "$status" in
              *enabled) echo "$name" > /proc/acpi/wakeup ;;
            esac
            ;;
        esac
      done < /proc/acpi/wakeup
    '';
  };

  # Battery safety net: if the machine is ever awake on a low battery (e.g. a
  # stray wake or a hybrid-sleep that won't power off), hibernate to save the
  # session instead of draining to a dead, lost-session shutdown.
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 15;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # --- Nix / system (moved here from the old nixos/configuration.nix aggregator) ---

  # Nix configuration
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # 4c/8t CPU + 16 GB RAM: cap concurrent derivations and threads-per-build
      # so a local build (cache miss) can't oversubscribe CPU or OOM.
      max-jobs = 4;
      cores = 2;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep 30 days of generations. configurationLimit (boot.nix) caps the boot
      # menu at 10; this bounds on-disk generations so weekly GC actually frees space.
      options = "--delete-older-than 30d";
    };
  };

  # nh: friendlier nixos-rebuild wrapper with a build diff (`nh os switch`).
  # GC stays handled by nix.gc above, so nh.clean is intentionally left off.
  programs.nh = {
    enable = true;
    flake = "/home/michael/nix-config";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Minimal system packages - only essentials for system administration
  # All user applications are now in home-manager for better portability
  environment.systemPackages = with pkgs; [
    vim              # Emergency editor if home-manager breaks
    git              # To clone/update this config repository
    claude-code      # System-level claude-code installation
    gemini-cli
  ];

  # NixOS state version - DO NOT CHANGE
  # This is NOT the NixOS version, it's a state compatibility marker
  system.stateVersion = "23.11";
}
