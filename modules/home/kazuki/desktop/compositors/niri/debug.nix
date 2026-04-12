{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.niri.settings.debug = {
    # Allows notification actions and window activation from Noctalia.
    honor-xdg-activation-with-invalid-serial = [ ];
  };
}
