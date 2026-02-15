{ config, lib, pkgs, ... }:

{
  # Sunshine game streaming server (Moonlight client compatible)
  # WebGUI: https://localhost:47990
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;  # Required for KMS/Wayland capture

    # Performance-optimized settings
    settings = {
      # Encoder settings - NVENC for hardware encoding with NVIDIA GPU
      encoder = "nvenc";

      # Streaming quality
      min_fps_factor = 1;    # Don't reduce FPS under load

      # Capture method - must match desktop session type
      # Using X11 capture since kde.nix sets defaultSession = "plasmax11"
      capture = "x11";

      # Thread count for better parallelism
      min_threads = 4;

      # Audio settings - use the virtual Sunshine sink
      audio_sink = "Sunshine-Sink";
    };
  };

  # Virtual audio sink for headless streaming
  # Creates a sink that Sunshine can capture audio from when no physical audio device exists
  services.pipewire.extraConfig.pipewire."91-sunshine-sink" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Sunshine-Sink";
          "node.description" = "Sunshine Audio Output";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
    ];
  };

  # Ensure uinput module is loaded for virtual input devices
  boot.kernelModules = [ "uinput" ];

  # udev rule to allow input group access to uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  # FFmpeg with encoding support for Sunshine
  environment.systemPackages = with pkgs; [
    ffmpeg-full  # Full FFmpeg with all encoders
  ];

  # Avahi for mDNS discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
