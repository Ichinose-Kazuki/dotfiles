{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.myModule.desktop.compositor == "hyprland") {
    # hyprlock
    security.pam.services.hyprlock = {
      # unlock kwallet upon unlocking lockscreen.
      kwallet = {
        enable = true;
      };
    };
  };
}
