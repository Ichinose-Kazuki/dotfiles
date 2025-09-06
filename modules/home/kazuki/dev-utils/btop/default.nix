{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.btop = {
    enable = true;
  };
}
