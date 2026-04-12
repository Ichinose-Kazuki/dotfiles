{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # Can be used on Wayland compositors supporting the wlr-output-management protocol
  # Criteria format: Make Model Serial. Check with wlr-randr command
  services.kanshi = {
    enable = true;
    settings = [
      { include = "${config.xdg.configHome}/kanshi/config.tmp"; } # Temporary config file
      {
        output.criteria = "PNP(JPN) JAPANNEXT MNT 0x00000001";
        output.scale = 1.5;
      }
      {
        profile.name = "undocked";
        profile.outputs = [ { criteria = "eDP-1"; } ];
      }
      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "PNP(JPN) JAPANNEXT MNT 0x01010101";
            position = "0,0";
          }
          {
            criteria = "PNP(JPN) JAPANNEXT MNT 0x00000001";
            position = "2560,0";
          }
        ];
      }
    ];
  };

  # Temporary config file must exist
  home.activation = {
    createKanshiTmp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD touch $VERBOSE_ARG ${config.xdg.configHome}/kanshi/config.tmp
    '';
  };
}
