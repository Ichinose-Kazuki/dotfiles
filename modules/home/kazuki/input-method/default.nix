{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./engine
    ./framework
  ];
}
