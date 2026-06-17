{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf (builtins.elem "wayland-utils" config.myModule.desktop.components) {
    environment.systemPackages = with pkgs; [
      grim # grab images from a Wayland compositor
      slurp # select a region of the screen
      wl-clipboard # copy/paste from stdin/stdout
      waypaper # works as a frontend for swaybg
    ];
  };
}
