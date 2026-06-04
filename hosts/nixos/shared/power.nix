{ ... }:

{
  # Logind power management
  # LidSwitchIgnoreInhibited=no ensures lid close always suspends even if
  # a session has suspend inhibited (which tuigreet might do)
  #
  # Battery-aware hibernate is achieved natively:
  #   - on battery, lid close -> suspend-then-hibernate (systemd suspends, then
  #     hibernates after HibernateDelaySec; see shared/hibernate.nix)
  #   - on AC/docked, lid close -> plain suspend (stay cool + responsive)
  # This replaces the old hand-rolled rtcwake scheme that could overheat if the
  # hibernate step hung with the lid shut.
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore"; # When external monitor connected
    LidSwitchIgnoreInhibited = "no";
  };
}
