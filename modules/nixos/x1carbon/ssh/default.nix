{ lib, pkgs, ... }:

{
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
  };
}
