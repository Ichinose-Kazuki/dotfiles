{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./colors.nix
    ./plugins.nix
    ./settings.nix
    ./wallpapers.nix
  ];

  # available options: https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    
  };
}
