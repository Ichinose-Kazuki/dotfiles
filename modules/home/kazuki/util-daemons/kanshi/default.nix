{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  services.kanshi = {
    settings = [
      # { include  = "path/to/temporary/settings/file"; }
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
