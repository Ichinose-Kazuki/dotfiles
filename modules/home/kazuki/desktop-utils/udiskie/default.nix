{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    services.udiskie = {
      enable = true;
    };
  };
}
