{ ... }:

{
  # TLP selects performance on AC and balanced on battery by default, so a
  # machine that boots while plugged in starts on performance. Assign
  # power-saver to both power sources so the default profile is power-saver;
  # the profile can still be changed at runtime from the desktop shell.
  services.tlp.settings = {
    TLP_PROFILE_AC = "SAV";
    TLP_PROFILE_BAT = "SAV";

    # TLP would otherwise pin the firmware platform profile to "performance"
    # while the performance profile is active, which keeps the embedded
    # controller running the fan hard even at moderate temperatures.
    PLATFORM_PROFILE_ON_AC = "balanced";
  };

  # Expose the power-profiles-daemon D-Bus interface so the profile can be
  # switched at runtime from a desktop shell.
  services.tlp.pd.enable = true;
}
