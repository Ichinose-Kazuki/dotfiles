{
  pkgs,
  lib,
  config,
  ...
}:

{
  # kwallet settings from plasma6 module.
  environment.systemPackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
    kcmutils
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
}
