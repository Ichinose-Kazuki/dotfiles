{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

{
  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "${config.xdg.dataHome}/windows_spotlight/image.jpg";
    };
  };
}
