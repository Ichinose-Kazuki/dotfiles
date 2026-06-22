{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    i18n = {
      inputMethod = {
        enable = true;
        type = "fcitx5";
      };
    };
  };
}
