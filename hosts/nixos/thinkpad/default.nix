{ inputs, lib, config, pkgs, ... }:

let
  # battery-charge: flip the charge limit between the 80% longevity cap and a
  # full 100% charge for travel / heavy days. The sysfs writes need root, so the
  # command just (re)starts the two oneshot units below; the polkit rule lets
  # michael do that without a password. Effect is immediate — no rebuild — and
  # the cap is re-applied on the next boot by battery-charge-threshold.service.
  batteryCharge = pkgs.writeShellApplication {
    name = "battery-charge";
    runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
    text = ''
      bat=/sys/class/power_supply/BAT0
      case "''${1:-status}" in
        full|100)
          systemctl restart battery-charge-full.service
          echo "Charging to 100% — reverts to the 80% cap on next reboot."
          ;;
        limit|80|cap)
          systemctl restart battery-charge-threshold.service
          echo "Charge capped at 80%."
          ;;
        status)
          printf 'start %s%%  stop %s%%  now %s%% (%s)\n' \
            "$(cat "$bat"/charge_control_start_threshold)" \
            "$(cat "$bat"/charge_control_end_threshold)" \
            "$(cat "$bat"/capacity)" \
            "$(cat "$bat"/status)"
          ;;
        *)
          echo "usage: battery-charge [full|limit|status]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  # Host-specific configuration for thinkpad

  # Hostname
  networking.hostName = "thinkpad";

  # Intel Iris Xe (11th gen Tiger Lake) hardware video acceleration
  # Required for Moonlight, mpv, Firefox, etc. to use GPU decoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API driver for Gen 8+ Intel (iHD)
      vpl-gpu-rt            # Intel Video Processing Library (QSV successor)
    ];
  };

  # Firefox hardware video decode (VA-API) on the Iris Xe iGPU — a real battery
  # win for video on battery (offloads H.264/VP9/AV1 decode to the GPU). The iHD
  # driver is provided above; pin it and run Firefox natively on Wayland so it can
  # use zero-copy dmabuf decoding instead of XWayland software decode.
  # NB: session variables — take effect on next login, not just a rebuild.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MOZ_ENABLE_WAYLAND = "1";
  };
  programs.firefox.preferences = {
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
  };
  programs.firefox.preferencesStatus = "default"; # defaults, still user-overridable

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

  # Run `powertop --auto-tune` at boot: enables runtime PM on PCI devices, audio
  # codec power-down, USB autosuspend, etc. (the "Bad" tunables powertop flags).
  # Caveat: USB autosuspend can make some external mice/keyboards/dongles need a
  # re-plug after wake — exclude a specific one with a udev power/control=on rule
  # if it misbehaves. (NB: PCIe ASPM is firmware-disabled on this ThinkPad — the
  # FADT declares it unsupported — so it stays off unless forced; see note below.)
  powerManagement.powertop.enable = true;

  # Cap battery charge at 80% on AC to slow lithium-ion wear when desk-bound.
  # Runs at every boot, so it also re-applies the cap after a full-charge day.
  # Flip it live with `battery-charge full` / `battery-charge limit` (see top).
  systemd.services.battery-charge-threshold = {
    description = "Limit battery charge to 80% for longevity";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    # Lower start before stop so start < stop holds even coming down from 95/100.
    script = ''
      echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
  };

  # Manual counterpart: charge all the way to 100% for travel / heavy days.
  # Started on demand by `battery-charge full`; deliberately NOT wanted at boot,
  # so the 80% cap always wins on a fresh start.
  systemd.services.battery-charge-full = {
    description = "Allow battery to charge to 100%";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    # Raise stop before start so start < stop holds while moving up from 75/80.
    script = ''
      echo 100 > /sys/class/power_supply/BAT0/charge_control_end_threshold
      echo 95  > /sys/class/power_supply/BAT0/charge_control_start_threshold
    '';
  };

  # Let michael (re)start the two battery units above without a password, so
  # `battery-charge` is a frictionless toggle instead of a sudo dance.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "michael") {
        var unit = action.lookup("unit");
        if (unit == "battery-charge-full.service" ||
            unit == "battery-charge-threshold.service") {
          return polkit.Result.YES;
        }
      }
    });
  '';

  # Auto-switch power-profiles-daemon on AC/battery transitions. PPD has no
  # built-in AC/battery awareness under niri, so on its own it just persists
  # whatever was last set — it kept getting stuck in "performance" on battery.
  # A udev event on the AC adapter (plug/unplug) triggers this oneshot, which
  # reads the live AC state and picks the profile:
  #   - on battery -> power-saver (EPP=power, platform_profile=low-power)
  #   - on AC      -> balanced
  # Also wanted at boot so the right profile is set from the start. You can still
  # bump to performance from DMS while plugged in; unplugging drops to power-saver.
  systemd.services.power-profile-ac = {
    description = "Set power profile from AC adapter state";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    path = [ pkgs.power-profiles-daemon ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = "1" ]; then
        powerprofilesctl set balanced
      else
        powerprofilesctl set power-saver
      fi
    '';
  };

  # Re-run the switch whenever the AC adapter changes state.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile-ac.service"
  '';

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
    batteryCharge    # battery-charge 80%/100% toggle (defined in let above)
    vim              # Emergency editor if home-manager breaks
    git              # To clone/update this config repository
    claude-code      # System-level claude-code installation
    codex
    gemini-cli
  ];

  # NixOS state version - DO NOT CHANGE
  # This is NOT the NixOS version, it's a state compatibility marker
  system.stateVersion = "23.11";
}
