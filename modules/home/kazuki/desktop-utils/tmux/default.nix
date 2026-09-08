{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:

{
  imports = [
    inputs.tmux-config.homeModules.default
  ];

  myTmux.enable = true;
}
