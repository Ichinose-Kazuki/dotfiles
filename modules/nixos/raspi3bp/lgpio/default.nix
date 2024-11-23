{ pkgs, ... }:

let
  lgpio = pkgs.callPackage ./lgpio.nix { };
in
{
  environment.systemPackages = [
    lgpio
    pkgs.gcc
  ];
}
