{ pkgs, config, lib, ... }:

{
  # Asus ROG Zephyrus G16 host configuration
  # Intel Core Ultra 9 185H + NVIDIA RTX 4090 Mobile

  networking.hostName = "zephyrus";

  # Intel CPU microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Intel Arc iGPU hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API driver (iHD)
      vpl-gpu-rt            # Intel Video Processing Library
    ];
  };

  # ============================================================================
  # ASUS ROG LAPTOP SERVICES
  # ============================================================================

  # asusd - Main Asus daemon for:
  # - Keyboard backlight (per-key RGB, zones, effects)
  # - Fan curves and performance profiles
  # - Battery charge limits
  # - ROG key handling
  # - Anime Matrix display (if equipped)
  services.asusd = {
    enable = true;

    # Fan curve profiles (optional custom config)
    # Default profiles: Quiet, Balanced, Performance
    # fanCurvesConfig = ''
    #   (
    #     ...custom fan curves...
    #   )
    # '';
  };

  # supergfxd - GPU mode switching daemon
  # Modes: Integrated, Hybrid, Dedicated, Vfio
  # Use: supergfxctl -m hybrid (or integrated/dedicated)
  services.supergfxd.enable = true;

  # ============================================================================
  # FIRMWARE & BIOS UPDATES
  # ============================================================================

  # fwupd - Linux Vendor Firmware Service
  # Asus laptops are well-supported for BIOS/firmware updates
  # Use: fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
  services.fwupd = {
    enable = true;
    # Enable testing releases for latest firmware
    extraRemotes = [ "lvfs-testing" ];
  };

  # ============================================================================
  # KERNEL & HARDWARE
  # ============================================================================

  # Use latest kernel for best hardware support on new laptops
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Asus-specific kernel modules
  boot.kernelModules = [
    "asus-wmi"        # Asus WMI hotkeys and features
    "asus-nb-wmi"     # Asus notebook WMI
  ];

  # Kernel parameters for Asus laptops
  boot.kernelParams = [
    # Enable ACPI backlight control
    "acpi_backlight=native"
    # Meteor Lake (Intel Core Ultra) only supports S0ix, not S3
    "mem_sleep_default=s2idle"
    # IOMMU passthrough for NVIDIA PRIME stability
    "iommu=pt"
  ];

  # Hardware quirks/fixes
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # ============================================================================
  # BLUETOOTH
  # ============================================================================

  # Bluetooth for wireless peripherals
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket,Input";
        Experimental = true;  # For battery reporting
      };
    };
  };
  services.blueman.enable = true;

  # ============================================================================
  # DISPLAY & SCREEN
  # ============================================================================

  # High refresh rate display support
  # The Zephyrus G16 has a 240Hz OLED display
  # Niri/Wayland handles refresh rate automatically

  # ============================================================================
  # SYSTEM CONFIGURATION
  # ============================================================================

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User account
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "render"
      "gamemode"
      "keyd"
      "uinput"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  # User-facing programs
  programs.firefox.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "michael" ];
  };
  programs.zsh.enable = true;

  # GDK pixbuf for image rendering
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # Enable CUPS for printing
  services.printing.enable = true;

  # Security
  security.polkit.enable = true;

  # uinput access for ydotool
  hardware.uinput.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    claude-code

    # Asus ROG tools
    asusctl         # Asus laptop control CLI (keyboard RGB, fan curves, etc.)
    supergfxctl     # GPU switching CLI

    # Firmware tools
    fwupd           # Firmware update CLI

    # System monitoring
    lm_sensors      # Hardware sensors
    powertop        # Power consumption analysis
    s-tui           # Terminal UI for CPU stress testing and monitoring

    # Brightness control
    brightnessctl   # Alternative brightness control
  ];

  # ============================================================================
  # SENSORS
  # ============================================================================

  # Hardware sensors for temperature monitoring
  # Use: sensors command after reboot
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # Additional sensor modules if needed
  ];

  # ============================================================================
  # EFI FALLBACK BOOT PATH (ASUS BIOS WORKAROUND)
  # ============================================================================
  # ASUS firmware resets EFI NVRAM boot order on cold boot. The UEFI spec
  # requires firmware to try EFI/BOOT/BOOTX64.EFI as a fallback unconditionally.
  # Copying systemd-boot there ensures NixOS always boots without BIOS intervention.
  system.activationScripts.efiBootFallback = {
    text = ''
      src="/boot/EFI/systemd/systemd-bootx64.efi"
      dst="/boot/EFI/BOOT/BOOTX64.EFI"
      if [ ! -f "$src" ]; then
        echo "WARNING: systemd-boot EFI binary not found at $src, skipping fallback install"
      else
        mkdir -p /boot/EFI/BOOT
        if ! cmp -s "$src" "$dst" 2>/dev/null; then
          cp "$src" "$dst"
          echo "Installed systemd-boot to EFI fallback path"
        fi
      fi
    '';
    deps = [];
  };

  system.stateVersion = "24.11";
}
