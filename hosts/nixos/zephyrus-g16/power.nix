{ ... }:

{
  # Power profiles via power-profiles-daemon + asusd
  # PPD maps to ASUS platform profiles: power-saver→Quiet, balanced→Balanced, performance→Performance
  # DMS panel and asusctl both control these profiles

  # Thermald for Intel thermal management
  services.thermald.enable = true;
}
