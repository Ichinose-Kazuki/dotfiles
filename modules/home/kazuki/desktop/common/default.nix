{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./pointer-cursor.nix
    # ./fonts.nix
    ./session-variables.nix
    # ./mime-apps.nix
    ./xdg-portal.nix
  ];
}
