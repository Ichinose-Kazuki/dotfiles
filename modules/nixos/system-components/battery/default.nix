{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./tlp.nix
    ./upower.nix
  ];
}
