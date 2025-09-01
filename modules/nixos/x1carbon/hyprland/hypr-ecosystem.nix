{
  pkgs,
  lib,
  config,
  ...
}:

{
  # hyprlock
  security.pam.services.hyprlock = {
    # unlock kwallet upon unlocking lockscreen.
    kwallet = {
      enable = true;
    };
  };
}
