{ pkgs, ... }:

{
  # User account configuration
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "keyd" "networkmanager" "wheel" ];
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

  # GNOME desktop disabled - using Hyprland instead
  # Keep gdk-pixbuf for image rendering support
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # PAM (Pluggable Authentication Modules) configuration
  # Enables password + fingerprint authentication for system services
  #
  # Why fprintAuth is better than text override:
  # - Uses NixOS's standard PAM module integration
  # - Properly sets up all required authentication modules
  # - Maintains compatibility with system updates
  # - Includes proper session and account management
  #
  # Authentication flow with fprintAuth:
  # 1. Fingerprint attempted first (pam_fprintd.so)
  # 2. Falls back to password if fingerprint fails/unavailable
  # 3. Both methods are "sufficient" - either one succeeds = authenticated
  #
  # Services configured:
  # - swaylock: Screen lock with fingerprint
  # - sudo: Privilege elevation with fingerprint
  # - greetd: Login screen with fingerprint
  # - login: Console login with fingerprint
  # - polkit-1: System authorization with fingerprint
  security.pam.services = {
    # Screen lock with fingerprint support
    swaylock.fprintAuth = true;

    # Privilege elevation with fingerprint
    sudo.fprintAuth = true;

    # Login screen with fingerprint
    greetd.fprintAuth = true;

    # Console login with fingerprint
    login.fprintAuth = true;

    # Polkit authorization dialogs with fingerprint
    polkit-1.fprintAuth = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable fingerprint reader
  # Device: 06cb:00bd Synaptics Prometheus MIS Touch Fingerprint Reader
  # Requires firmware update via fwupd to work properly
  services.fprintd.enable = true;

  # Firmware update daemon (required for fingerprint reader firmware)
  # Run: fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
  services.fwupd.enable = true;

  security.polkit.enable = true;
}
