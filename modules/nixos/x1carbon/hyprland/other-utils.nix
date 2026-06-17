{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.myModule.desktop.compositor == "hyprland") {
    # programs.nm-applet.enable = true;
  };
}
