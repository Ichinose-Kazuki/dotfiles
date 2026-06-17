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
  imports = lib.optionals isNoctalia [
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
