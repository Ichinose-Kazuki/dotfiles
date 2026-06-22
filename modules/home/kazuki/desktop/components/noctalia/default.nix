{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

let
  isNoctalia = builtins.elem "noctalia" osConfig.myModule.home.desktopComponents;
in
{
  # Imported unconditionally so `programs.noctalia-shell` is always declared
  # (needed under whole-tree import — the sibling colors/plugins/settings/
  # wallpapers modules reference it under their own mkIf guards). Activation is
  # gated by the mkIf below.
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # available options: https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix
  config = lib.mkIf isNoctalia {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = false; # deprecated
    };

    home.packages = with pkgs; [
      # Dependency for clipboard auto-paste
      wtype
    ];
  };
}
