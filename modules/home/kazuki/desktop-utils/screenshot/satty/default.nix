{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  config = lib.mkIf (builtins.elem "satty" osConfig.myModule.home.screenshots) {
    # Setup from https://nickjanetakis.com/blog/wayland-compatible-annotated-screenshots-with-slurp-grim-and-satty
    home.packages = [
      (pkgs.callPackage ./_screenshot-script.nix { inherit osConfig; })
    ];
  };
}
