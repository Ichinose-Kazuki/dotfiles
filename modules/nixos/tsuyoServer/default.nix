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
    ../files # for GoPro
    ../x1carbon/docker
  ];

  environment.systemPackages = with pkgs; [
    unzip
  ];
}
