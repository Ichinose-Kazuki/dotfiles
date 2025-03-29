{ lib, pkgs, ... }:

{
  # Client side
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    # ! TODO
    # askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
  };

  # Server side
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  };
}
