{ config, lib, ... }:

{
  config = lib.mkIf (config.myModule.desktop.displayManager == "ly") {
    services.displayManager.ly.enable = true;
  };
}
