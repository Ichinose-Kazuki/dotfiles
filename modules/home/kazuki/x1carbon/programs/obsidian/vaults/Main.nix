{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf osConfig.myModule.home.obsidian {
    programs.obsidian.vaults."Main" = {
      enable = true;
      target = "obsidian/Main";
    };
  };
}
