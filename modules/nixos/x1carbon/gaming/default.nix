{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.myModule.hardware.gaming {
    programs.steam.enable = true;
  };
}
