{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./upower.nix
  ];
}
