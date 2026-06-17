{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (builtins.elem "antigravity" osConfig.myModule.home.editors) {
    home.packages = with pkgs; [
      antigravity-fhs
    ];
  };
}
