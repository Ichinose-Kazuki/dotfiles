{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "confirm";
    includes = [ "conf.d/*" ];
  };
}
