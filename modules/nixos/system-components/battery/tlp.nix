{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # TLP's default performance profile pins the firmware platform profile to
  # "performance" while on AC, which keeps the embedded controller running the
  # fan hard even at moderate temperatures.
  services.tlp.settings.PLATFORM_PROFILE_ON_AC = "balanced";

  # Expose the power-profiles-daemon D-Bus interface so the profile can be
  # switched at runtime from a desktop shell.
  services.tlp.pd.enable = true;
}
