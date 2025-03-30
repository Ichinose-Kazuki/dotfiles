{ inputs, pkgs, ... }:

{
  imports = [
    ./kdePackages.nix
  ];

  services.desktopManager.plasma6.enable = true;
}
