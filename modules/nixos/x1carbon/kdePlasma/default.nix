{ inputs, pkgs, lib, config, ... }:

{
  config = lib.mkIf (builtins.elem "kdePlasma" config.myModule.desktop.components) {
    services.desktopManager.plasma6.enable = true;
    i18n.inputMethod.fcitx5.plasma6Support = true;
  };
}
