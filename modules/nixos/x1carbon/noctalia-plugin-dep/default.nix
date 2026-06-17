{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = lib.mkIf (builtins.elem "gpu-recorder" config.myModule.desktop.components) {
    programs.gpu-screen-recorder.enable = true;
  };
}
