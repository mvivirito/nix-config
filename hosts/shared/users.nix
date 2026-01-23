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

  # Security: PAM configuration for swaylock
  # Enables screen locking with password + fingerprint authentication
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };

  security.polkit.enable = true;
}
