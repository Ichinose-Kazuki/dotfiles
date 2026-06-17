{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  config = lib.mkIf (builtins.elem "files" config.myModule.desktop.components) {
    services.gvfs.enable = true;
  };
}
