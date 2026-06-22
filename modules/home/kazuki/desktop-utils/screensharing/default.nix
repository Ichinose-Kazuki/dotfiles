{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    # tutorial: https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580
    # xdg-desktop-portal-hyprland has the variables already
    programs.obs-studio = {
      enable = true;
    };

    # for XWayland apps: https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/#xwayland
  };
}
