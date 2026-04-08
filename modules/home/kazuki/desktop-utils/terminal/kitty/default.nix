{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # terminal
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    enableGitIntegration = true;
    # Mappable actions: https://sw.kovidgoyal.net/kitty/actions
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
    };
    # About kitty.conf: https://sw.kovidgoyal.net/kitty/conf
    settings = {
      tab_bar_edge = "top";
      tab_bar_min_tabs = 1;
      window_padding_width = "5 5";
    };
    # run "kitten themes" to preview all themes.
    themeFile = "Chalk"; # afterglow, bluloco dark, broadcast, chalk,
  };
}
