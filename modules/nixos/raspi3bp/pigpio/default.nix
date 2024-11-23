{ pkgs, ... }:

let
  pigpio = pkgs.callPackage ./pigpio.nix { };
in
{
  environment.systemPackages = [
    pigpio
    pkgs.gcc
  ];
}
