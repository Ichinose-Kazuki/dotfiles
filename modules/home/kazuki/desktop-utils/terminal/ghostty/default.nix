{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    clearDefaultKeybinds = true;
    settings = {
      theme = "Chalk";

      window-padding-x = 5;
      window-padding-y = 5;

      mouse-scroll-multiplier = "discrete:1";

      gtk-tabs-location = "top";

      keybind = [
        "ctrl+equal=increase_font_size:2"
        "ctrl+minus=decrease_font_size:2"
        "ctrl+v=paste_from_clipboard"
        "performable:ctrl+c=copy_to_clipboard"
      ];
    };
  };
}
