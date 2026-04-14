{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./community-plugins
    ./core-plugins
    ./vaults
  ];

  programs.obsidian.enable = true;
}
