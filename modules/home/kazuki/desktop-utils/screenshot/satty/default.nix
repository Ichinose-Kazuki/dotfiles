{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # Setup from https://nickjanetakis.com/blog/wayland-compatible-annotated-screenshots-with-slurp-grim-and-satty
  imports = [
    ./satty.nix
  ];

  home.packages = [
    (pkgs.callPackage ./screenshot-script.nix { inherit osConfig; })
  ];
}
