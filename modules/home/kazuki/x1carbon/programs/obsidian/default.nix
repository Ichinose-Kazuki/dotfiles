{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./sync.nix
  ];

  programs.obsidian.enable = true;
}
