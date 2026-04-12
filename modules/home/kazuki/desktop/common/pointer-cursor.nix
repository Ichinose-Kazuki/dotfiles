{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.pointerCursor = {
    size = 36;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    gtk.enable = true;
    x11.enable = true;
  };
}
