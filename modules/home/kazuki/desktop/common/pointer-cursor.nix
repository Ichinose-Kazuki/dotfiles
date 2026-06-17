{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.home.compositor != "none") {
    home.pointerCursor = {
      size = 36;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
