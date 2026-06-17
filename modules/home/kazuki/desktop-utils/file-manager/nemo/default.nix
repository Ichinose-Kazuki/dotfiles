{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # nemo is always-on when a desktop compositor is active.
  # (Previously only loaded via hyprland/other-utils.nix for hyprland users.)
  config = lib.mkIf (osConfig.myModule.home.compositor == "hyprland") {
    home.packages = with pkgs; [
      # installs folder-color-switcher, nemo-emblems, nemo-fileroller, nemo-python by default.
      (nemo-with-extensions.override { extensions = [ nemo-preview ]; })
    ];
  };
}
