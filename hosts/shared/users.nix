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

  # PAM (Pluggable Authentication Modules) configuration for swaylock
  # Enables screen locking with password + fingerprint authentication
  #
  # Why needed:
  # - swaylock needs permission to verify passwords (PAM integration)
  # - Without this, swaylock can't unlock (security issue)
  #
  # Authentication flow:
  # 1. try_first_pass: Try password from previous PAM module (if any)
  # 2. pam_unix.so: Standard Unix password authentication (/etc/shadow)
  #    - likeauth: use same auth method as login
  #    - nullok: allow empty passwords (convenient for development/testing)
  #    - sufficient: if this succeeds, skip remaining modules
  # 3. pam_fprintd.so: Fingerprint authentication via fprintd service
  #    - sufficient: if this succeeds, skip remaining modules
  #    - Runs if password fails or user chooses fingerprint
  # 4. Fall back to 'login' PAM stack if both fail
  #
  # Security consideration:
  # - 'nullok' allows empty passwords (convenient but less secure)
  # - Consider removing 'nullok' if not needed for testing
  # - Fingerprint is alternative auth method (not additional security)
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };

  security.polkit.enable = true;
}
