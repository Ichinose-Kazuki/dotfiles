{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./clipboard-manager
    ./screensharing
    ./screenshot
    ./terminal
    ./udiskie
  ];
}
