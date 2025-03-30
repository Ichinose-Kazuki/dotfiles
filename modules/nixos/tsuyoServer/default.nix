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
  ];

  environment.systemPackages = with pkgs; [
    unzip
  ];
}
