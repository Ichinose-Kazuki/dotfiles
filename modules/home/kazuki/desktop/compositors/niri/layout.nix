{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md
  # wiki: https://github.com/niri-wm/niri/wiki/Configuration:-Layout
  # todo: should use very-refactor instead
  programs.niri.settings.layout = {
    gaps = 16;
    center-focused-column = "never";
    always-center-single-column = true;
    empty-workspace-above-first = true;
    default-column-display = "tabbed";
    background-color = "#003300";

    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    default-column-width = {
      proportion = 0.5;
    };

    preset-window-heights = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];

    focus-ring = {
      enable = true;
      width = 4;
      # active-color = "#7fc8ff";
      # inactive-color = "#505050";
      # urgent-color = "#9b0000";
      # active-gradient from="#80c8ff" to="#bbddff" angle=45
      # inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
      # urgent-gradient from="#800" to="#a33" angle=45
    };

    border = {
      enable = false;
      width = 4;
      # active-color = "#ffc87f";
      # inactive-color = "#505050";
      # urgent-color = "#9b0000";
      # active-gradient from="#ffbb66" to="#ffc880" angle=45 relative-to="workspace-view"
      # inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view" in="srgb-linear"
      # urgent-gradient from="#800" to="#a33" angle=45
    };

    shadow = {
      enable = false;
      softness = 30;
      spread = 5;
      offset = {
        x = 0;
        y = 5;
      };
      draw-behind-window = true;
      color = "#00000070";
      # inactive-color "#00000054"
    };

    tab-indicator = {
      enable = true;
      hide-when-single-tab = true;
      place-within-column = true;
      gap = 5;
      width = 4;
      length.total-proportion = 1.0;
      position = "right";
      gaps-between-tabs = 2;
      corner-radius = 8;
      # active-color = "red";
      # inactive-color = "gray";
      # urgent-color = "blue";
      # active-gradient from="#80c8ff" to="#bbddff" angle=45
      # inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
      # urgent-gradient from="#800" to="#a33" angle=45
    };

    # insert-hint = {
    #   enable = true;
    #   color = "#ffc87f80";
    #   # gradient from="#ffbb6680" to="#ffc88080" angle=45 relative-to="workspace-view"
    # };

    struts = {
      # left 64
      # right 64
      # top 64
      # bottom 64
    };
  };
}
