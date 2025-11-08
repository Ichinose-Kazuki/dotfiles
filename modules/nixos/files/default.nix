{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # filesystem, file manager
  imports = [
    ./gvfs
  ];
}
