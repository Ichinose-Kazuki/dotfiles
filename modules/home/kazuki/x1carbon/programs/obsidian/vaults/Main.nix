{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.obsidian.vaults."Main" = {
    enable = true;
    target = "obsidian/Main";
  };
}
