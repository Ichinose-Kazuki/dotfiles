{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.packages =
    with pkgs;
    lib.mkIf osConfig.programs.hyprland.enable [
      grimblast
      # dependencies of grimblast
      coreutils
      grim
      hyprpicker
      jq
      libnotify
      slurp
      wl-clipboard
      # utils
      swappy
      zenity
    ];
}
