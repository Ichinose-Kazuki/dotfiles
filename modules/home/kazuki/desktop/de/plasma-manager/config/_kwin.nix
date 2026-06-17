{ config }:

{
  kwinrc = {
    Wayland."InputMethod" = {
      shellExpand = true;
      value = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
    };
    "Effect-overview" = {
      BorderActivate = "9";
    };
  };
  "kwinoutputconfig.json" = {
    source = ./kwinoutputconfig.json;
    target = "kwinoutputconfig.json_nixstore";
    onChange = "cat ${config.xdg.configHome}/kwinoutputconfig.json_nixstore > ${config.xdg.configHome}/kwinoutputconfig.json";
  };
}
