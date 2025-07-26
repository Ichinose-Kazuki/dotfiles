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
  };

  # kwallet settings from plasma6 module.
  environment.systemPackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
  ];
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs.kdePackages; [ kwallet ];
  };
  security.pam.services = {
    login.kwallet = {
      enable = true;
      forceRun = true;
      package = pkgs.kdePackages.kwallet-pam;
    };
  };

  # not sure if this is needed. see description of hm xdg.portal.
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
