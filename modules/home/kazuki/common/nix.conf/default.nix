{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # secret nix.conf file
  home.sessionVariables = {
    NIX_USER_CONF_FILES = "${xdg.configHome}/nix/nix.conf";
    # to increase github API rate limit:
    # access-tokens = github.com=***
  };
}
