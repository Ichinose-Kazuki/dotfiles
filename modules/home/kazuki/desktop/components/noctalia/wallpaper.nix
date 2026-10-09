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
  imports = [
    # wallpaper
    ../../components/windows-spotlight
  ];

  windows-spotlight = {
    enable = true;
    imageFilepath = wallpaperPath;
    # Noctalia v5 reads the wallpaper path as an absolute argument; the command
    # must also be absolute because systemd resolves bare names with its own
    # PATH.
    reloadCommand = "${lib.getExe' config.programs.noctalia.package "noctalia"} msg wallpaper-set \"${wallpaperPath}\"";
  };

  programs.noctalia.settings.wallpaper = {
    enabled = true;
    fill_mode = "crop";
    transition_duration = 1500.0;
    transition_on_startup = false;
  };
}
