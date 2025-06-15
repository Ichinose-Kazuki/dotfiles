{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  wallpaperPath = "${config.xdg.dataHome}/windows_spotlight/image.jpg";
in
{
  # wallpaper
  imports = [
    ./windows-spotlight
  ];
  windows-spotlight = {
    imageFilepath = wallpaperPath;
    requiredService = "hyprpaper.service";
    reloadCommand = "${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper reload ,\"${wallpaperPath}\"";
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ wallpaperPath ];
      wallpaper = [ wallpaperPath ];
    };
  };
}
