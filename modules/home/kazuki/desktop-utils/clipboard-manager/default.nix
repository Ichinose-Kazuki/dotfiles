{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  services.clipse = {
    enable = true;
    historySize = 30;
  };
}
