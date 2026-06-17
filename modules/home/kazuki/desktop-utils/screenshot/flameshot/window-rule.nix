{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (builtins.elem "flameshot" osConfig.myModule.home.screenshots) {
    programs.niri.settings.window-rules = [
      {
        matches = [ { app-id = "flameshot"; } ];
        draw-border-with-background = false;
        open-floating = true;
        open-fullscreen = true;
        default-floating-position = {
          x = 0;
          y = 0;
          relative-to = "top-left";
        };
      }
    ];
  };
}
