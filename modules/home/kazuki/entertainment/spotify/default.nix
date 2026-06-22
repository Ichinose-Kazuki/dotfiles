{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    home.packages = with pkgs; [
      spotify
      spotify-cli-linux
      spotify-tray
    ];
  };
}
