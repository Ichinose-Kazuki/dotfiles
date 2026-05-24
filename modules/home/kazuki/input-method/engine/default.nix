{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./mozc
  ];
}
