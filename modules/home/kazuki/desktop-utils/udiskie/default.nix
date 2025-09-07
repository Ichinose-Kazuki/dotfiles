{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  services.udiskie = {
    enable = true;
  };
}
