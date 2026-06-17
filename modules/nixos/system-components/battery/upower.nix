{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.myModule.hardware.battery {
    services.upower.enable = true;
  };
}
