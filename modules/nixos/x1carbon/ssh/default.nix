{ lib, pkgs, ... }:

{
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    # ! TODO
    # askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
  };
}
