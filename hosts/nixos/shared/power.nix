{ ... }:

{
  # Logind power management
  # LidSwitchIgnoreInhibited=no ensures lid close always suspends even if
  # a session has suspend inhibited (which tuigreet might do)
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore"; # When external monitor connected
    LidSwitchIgnoreInhibited = "no";
  };
}
