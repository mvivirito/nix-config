{ pkgs, ... }:

{
  # Enable Theme
  environment.variables.GTK_THEME = "Catppuccin-Macchiato-Standard-Teal-Dark";
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";
  console = {
    earlySetup = true;
    colors = [
      "24273a"
      "ed8796"
      "a6da95"
      "eed49f"
      "8aadf4"
      "f5bde6"
      "8bd5ca"
      "cad3f5"
      "5b6078"
      "ed8796"
      "a6da95"
      "eed49f"
      "8aadf4"
      "f5bde6"
      "8bd5ca"
      "a5adcb"
    ];
  };

  # Override packages
  nixpkgs.config.packageOverrides = pkgs: {
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ]; # You can specify multiple accents here to output multiple themes 
      size = "standard";
      variant = "macchiato";
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-gtk
    catppuccin-kvantum
  ];
}
