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
    ./file-manager
    ./screensharing
    ./screenshot
    ./terminal
    ./udiskie
  ];
}
