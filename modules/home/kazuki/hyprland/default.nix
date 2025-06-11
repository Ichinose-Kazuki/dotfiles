{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
  };

  home.packages = with pkgs; [ kitty ];

  xdg.configFile."hypr/hyprland.conf".source =
    lib.mkForce "${osConfig.programs.hyprland.package}/share/hypr/hyprland.conf";
}
