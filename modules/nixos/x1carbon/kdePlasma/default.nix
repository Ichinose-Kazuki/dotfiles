{ inputs, pkgs, ... }:

{
  imports = [
    ./kdePackages.nix
  ];

  services.desktopManager.plasma6.enable = true;
  i18n.inputMethod.fcitx5.plasma6Support = true;
}
