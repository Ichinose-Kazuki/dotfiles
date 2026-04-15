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
    ../clipboard
  ];

  # available options: https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    # Dependency for clipboard auto-paste
    wtype
  ];
}
