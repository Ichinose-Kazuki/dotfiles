{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";

    # Default apps
    TERMINAL = "kitty";
    EDITOR = "vim";
  };
}
