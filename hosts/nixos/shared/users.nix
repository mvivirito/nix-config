{ pkgs, ... }:

{
  # User account configuration
  users.users.michael = {
    isNormalUser = true;
    description = "Michael Vivirito";
    extraGroups = [ "input" "keyd" "networkmanager" "uinput" "wheel" ];
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

  # Enable CUPS for printing
  services.printing.enable = true;

  # Firmware update daemon
  services.fwupd.enable = true;

  security.polkit.enable = true;

  # uinput access for ydotool (used by dictation)
  hardware.uinput.enable = true;
}
