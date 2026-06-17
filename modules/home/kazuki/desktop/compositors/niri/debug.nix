{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.home.compositor == "niri") {
    programs.niri.settings.debug = {
      # Allows notification actions and window activation from Noctalia.
      honor-xdg-activation-with-invalid-serial = [ ];
    };
  };
}
