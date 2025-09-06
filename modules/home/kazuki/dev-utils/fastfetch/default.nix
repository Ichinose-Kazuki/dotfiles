{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.fastfetch = {
    enable = true;
  };
}
