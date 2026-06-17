{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
    };
  };
}
