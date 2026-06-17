{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (builtins.elem "grimblast" osConfig.myModule.home.screenshots) {
    # hyprland screenshot utility
    home.packages =
      with pkgs;
      [
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
  };
}
