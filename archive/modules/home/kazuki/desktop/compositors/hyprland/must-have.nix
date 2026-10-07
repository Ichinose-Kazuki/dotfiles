{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
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

}
