{ pkgs, ... }:

{
  # Audio configuration with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable fingerprint reader
  services.fprintd.enable = true;
}
