{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.niri.settings.window-rules = [
    {
      # Matches all windows
      geometry-corner-radius = {
        top-left = 8.0;
        top-right = 8.0;
        bottom-left = 8.0;
        bottom-right = 8.0;
      };
      clip-to-geometry = true;
    }
    {
      matches = [ { app-id = "Obsidian"; } ];
      default-column-width = {
        proportion = 0.3;
      };
    }
  ];
}
