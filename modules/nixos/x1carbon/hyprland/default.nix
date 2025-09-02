{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./must-have.nix
    ./hypr-ecosystem.nix
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # debug = true to enable debug logging
    package = pkgs.hyprland.override { debug = false; };
  };

  # not sure if this is needed. see description of hm xdg.portal.
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
