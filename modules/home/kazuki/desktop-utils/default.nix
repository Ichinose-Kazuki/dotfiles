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
    ./udiskie
  ];
}
