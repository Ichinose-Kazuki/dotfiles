{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../common/gopro
    ../x1carbon/docker
  ];

  environment.systemPackages = with pkgs; [
    unzip
  ];
}
