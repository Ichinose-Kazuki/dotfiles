{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.packages = with pkgs; [
    antigravity-fhs
  ];
}
