{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # can be used on Wayland compositors supporting the wlr-output-management protocol
  services.kanshi = {
    settings = [
      { include = "${config.xdg.dataHome}/kanshi/config.tmp"; } # temporary config file
      {
        output.criteria = "JPN JAPANNEXT MNT 0x00000001";
        output.scale = 1.5;
      }
      {
        profile.name = "undocked";
        profile.outputs = [ { criteria = "eDP-1"; } ];
      }
      {
        profile.name = "home";
        profile.outputs = [
          { criteria = "JPN JAPANNEXT MNT 0x01010101"; }
          { criteria = "JPN JAPANNEXT MNT 0x00000001"; }
        ];
      }
    ];
  };
}
