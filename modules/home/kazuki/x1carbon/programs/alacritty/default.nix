{
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf (builtins.elem "alacritty" osConfig.myModule.home.terminals) {
    programs.alacritty = {
      enable = true;
    };
  };
}
