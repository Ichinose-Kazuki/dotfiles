{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf (config.myModule.desktop.compositor == "sway") {
    programs.sway = {
      enable = true;
    };
  };
}
