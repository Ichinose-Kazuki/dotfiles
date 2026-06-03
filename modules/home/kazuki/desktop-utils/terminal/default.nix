{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./ghostty
    ./kitty
  ];
}
