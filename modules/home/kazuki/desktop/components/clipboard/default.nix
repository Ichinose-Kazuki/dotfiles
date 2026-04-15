{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./wl-clip-persist.nix
  ];
}
