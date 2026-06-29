{ ... }:

{
  # Timezone and internationalization
  time.timeZone = "America/Los_Angeles";

  # NTP — prefer homefw (local) at home, fall back to public servers when traveling.
  # Both go in `servers` on purpose: systemd-timesyncd's fallbackServers only apply
  # when `servers` is empty, so they would NOT fail over from an unreachable home
  # server. homefw is listed first → used at home, skipped (→ Cloudflare/Google) away.
  services.timesyncd.servers = [ "10.0.0.1" "time.cloudflare.com" "time.google.com" ];

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console configuration
  # Advanced key remapping is handled by kanata (see nixos/kanata/)
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };
}
