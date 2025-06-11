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
    package = osConfig.programs.hyprland.package; # enable hot reload.
    portalPackage = null; # portal package is added forcibly in nixos module.
  };

  home.packages = with pkgs; [ kitty ]; # recommended by hyprland?

  xdg.configFile."hypr/hyprland.conf".source =
    lib.mkForce "${osConfig.programs.hyprland.package}/share/hypr/hyprland.conf";

  xdg.portal = {
    enable = lib.mkForce true; # is set false in the hyprland module.
    xdgOpenUsePortal = true; # resolves bugs involving programs opening inside FHS etc.
    extraPortals = (with pkgs; [ xdg-desktop-portal-gtk ]) # coverage of each portal: https://wiki.archlinux.org/title/XDG_Desktop_Portal. xdg-desktop-portal-hyprland is added in the hyprland module.
      ++ osConfig.xdg.portal.extraPortals; # https://github.com/nix-community/home-manager/issues/7124
  };   
}
