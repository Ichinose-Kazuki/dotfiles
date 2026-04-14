{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Settings are written in `data.json`
  imports = [
    ./remotely-save.nix
  ];
}
