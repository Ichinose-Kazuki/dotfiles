{ config
, lib
, pkgs
, inputs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    unzip
  ];
}
