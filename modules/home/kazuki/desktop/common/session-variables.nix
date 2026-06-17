{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.home.compositor != "none") {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";

      # Default apps
      TERMINAL = osConfig.myModule.home.defaultTerminal;
      EDITOR = "vim";
    };
  };
}
