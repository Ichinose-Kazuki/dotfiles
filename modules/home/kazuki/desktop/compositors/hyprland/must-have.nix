{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.home.compositor == "hyprland") {
    # notification center
    services.swaync = {
      enable = true;
    };

    # volume/brightness OSD indicator
    services.swayosd = {
      enable = true;
    };

    # authentication agent
    services.hyprpolkitagent = {
      enable = true;
    };
  };
}
