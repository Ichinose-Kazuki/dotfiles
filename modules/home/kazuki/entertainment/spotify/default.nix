{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.packages = with pkgs; [
    spotify
    spotify-cli-linux
    spotify-tray
  ];
}
