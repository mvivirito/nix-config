{ ... }:

{
  # Logind power management
  # LidSwitchIgnoreInhibited=no ensures lid close always suspends even if
  # a session has suspend inhibited (which tuigreet might do)
  #
  # Battery-aware hibernate is achieved natively:
  #   - on battery OR AC, lid close -> suspend-then-hibernate (systemd suspends,
  #     then hibernates after HibernateDelaySec; see shared/hibernate.nix).
  #     AC uses the same path on purpose: charging must NOT prevent hibernation.
  #   - docked (external display) -> lid close ignored (HandleLidSwitchDocked).
  # This replaces the old hand-rolled rtcwake scheme that could overheat if the
  # hibernate step hung with the lid shut.
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore"; # When external monitor connected
    LidSwitchIgnoreInhibited = "no";
  };
}
